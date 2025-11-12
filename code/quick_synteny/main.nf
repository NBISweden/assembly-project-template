#!/usr/bin/env nextflow

/*
 * Nextflow pipeline for quick synteny plotting using miniprot, AGAT and JCVI.
 * Original shell script by Guilherme Dias (shared internally)
 */

workflow {

    main:
    genomes = channel.fromPath(params.genomes_csv, checkIfExists: true)
        .splitCsv(header: ['species', 'genome_fasta'])
        .map { row -> tuple(row.species, file(row.genome_fasta, checkIfExists: true)) }
    protein_database = channel.fromPath(params.protein_db, checkIfExists: true)

    ALIGN_PROTEOME(genomes, protein_database.collect())
    EXTRACT_CDS_AND_BED(ALIGN_PROTEOME.out.gff.join(genomes))
    SELECT_SEQUENCES(EXTRACT_CDS_AND_BED.out.bed.collect(), params.min_genes)
    ADD_MOCK_FEATURES(genomes, SELECT_SEQUENCES.out.ids)
    REFORMAT_FASTA(EXTRACT_CDS_AND_BED.out.cds_fasta)
    species_pairs = REFORMAT_FASTA.out.cds
        .join(ADD_MOCK_FEATURES.out.chromend_bed)
        .toList()
        .flatMap { species_list ->
            species_list
                .subsequences()
                .findAll { subseqs -> subseqs.size() == 2 }
                .collect { pair -> pair.flatten() }
        }
    JCVI_SYNTENY_PLOT(species_pairs)

    publish:
    karyotype_pdf = JCVI_SYNTENY_PLOT.out.karyotype_pdf
}

output {
    karyotype_pdf {
        path 'karotype_plot'
    }
}

process ALIGN_PROTEOME {
    tag species_name
    container 'community.wave.seqera.io/library/miniprot:0.18--c029dc85c45002bd'

    input:
    tuple val(species_name), path(genome_fasta)
    path protein_database

    script:
    """
    echo "Building miniprot index: ${species_name}.mpi"
    miniprot -t ${task.cpus} -d ${species_name}.mpi ${genome_fasta}

    echo "Running miniprot alignment -> ${species_name}.gff"
    miniprot -t ${task.cpus} -I -u --gff ${species_name}.mpi ${protein_database} > ${species_name}.gff
    """

    output:
    tuple val(species_name), path("${species_name}.gff"), emit: gff
    tuple val(species_name), path("${species_name}.mpi"), emit: index
    tuple val('miniprot'), eval('miniprot --version'), topic: versions
}

process EXTRACT_CDS_AND_BED {
    tag species_name
    container 'community.wave.seqera.io/library/agat:1.5.1--ae3cd948ce5e9795'

    input:
    tuple val(species_name), path(gff_file), path(genome_fasta)

    script:
    """
    echo "Extracting CDS sequences -> ${species_name}_cds.fa"
    agat_sp_extract_sequences.pl -g ${gff_file} -f ${genome_fasta} -t cds -o ${species_name}_cds.fa

    echo "Converting GFF -> BED: ${species_name}.bed"
    agat_convert_sp_gff2bed.pl --gff ${gff_file} -o ${species_name}.bed
    """

    output:
    path "${species_name}_cds.fa", emit: cds_fasta
    path "${species_name}.bed", emit: bed
    tuple val('agat'), eval('agat --version | cut -c2-'), topic: versions
}

process SELECT_SEQUENCES {
    container 'community.wave.seqera.io/library/ucsc-fasize:482--b17e2bc2f92b3fa7'

    input:
    path bed_files
    val min_genes

    script:
    """
    # get seq ids, will only draw ideograms for seqs with at least n genes
    echo "Selecting seqids with >= ${min_genes} genes"
    for BED in *.bed; do
        awk -v n=${min_genes} '{ a[\$1][\$4]=1 } END { for(f in a) { c=0; for(v in a[f]) c++; if(c>=n) b=(b?b","f:f)} print b}' \$BED
    done | \\
    tr ',' '\\\\n' > seqids.long
    """

    output:
    path "seqids.long", emit: ids
    tuple val('awk'), eval("awk --version | sed '1!d; s/mawk //; s/ .*//'"), topic: versions
}

process ADD_MOCK_FEATURES {
    tag species_name
    container 'community.wave.seqera.io/library/ucsc-fasize:482--b17e2bc2f92b3fa7'

    input:
    tuple val(species_name), path(genome_fasta)
    path seqids

    script:
    """
    echo "Getting fa sizes for selected sequences -> ${species_name}.chrom.sizes"
    faSize -detailed ${genome_fasta} | grep -f ${seqids} > ${species_name}.chrom.sizes

    echo "Creating chromEnd-marked BED -> ${species_name}_chromEndMarked.bed"
    awk -v FS="\\\\t" '{print \$1"\\\\t"(\$2-1)"\\\\t"\$2"\\\\t"\$1".chromEnd\\\\t0\\\\t."}' ${species_name}.chrom.sizes \\
        | cat ${species_name}.bed - \\
        | sort -k1,1 -k2,2n > ${species_name}_chromEndMarked.bed
    """

    output:
    tuple val(species_name), path("${species_name}_chromEndMarked.bed"), emit: chromend_bed
    tuple val(species_name), path("${species_name}.chrom.sizes"), emit: chrom_sizes
    tuple val('faSize'), val('482'), topic: versions
}

process REFORMAT_FASTA {
    tag species_name
    container 'community.wave.seqera.io/library/jcvi:1.5.7--6e88a2d9189b79d4'

    input:
    tuple val(species_name), path(cds_fasta)

    script:
    """
    echo "Formatting CDS FASTA for JCVI -> ${species_name}.cds"
    python -m jcvi.formats.fasta format ${cds_fasta} ${species_name}.cds
    """

    output:
    tuple val(species_name), path("${species_name}.cds"), emit: cds
    tuple val('jcvi'), eval("python -m jcvi.graphics.karyotype --help | sed '\$!d; s/.*libraries //;s/ .*//'"), topic: versions
}

process JCVI_SYNTENY_PLOT {
    tag "${species1}_${species2}"
    container 'community.wave.seqera.io/library/jcvi:1.5.7--6e88a2d9189b79d4'

    input:
    tuple val(species1), path(cds1), path(bed1), val(species2), path(cds2), path(bed2)

    script:
    """
    echo "Running jcvi.compara.catalog ortholog ${species1} ${species2}"
    python -m jcvi.compara.catalog ortholog ${species1} ${species2} --no_strip_names

    echo "Screening anchors -> ${species1}.${species2}.anchors.simple"
    python -m jcvi.compara.synteny screen --minspan=30 --simple ${species1}.${species2}.anchors ${species1}.${species2}.anchors.simple

    cat <<-EOF > layout
    # y, xstart, xend, rotation, color, label, va,  bed
     .6,     .1,    .8,       0,      , ${species1}, top, ${bed1}
     .4,     .1,    .8,       0,      , ${species2}, bottom, ${bed2}
    # edges
    e, 0, 1, ${species1}.${species2}.anchors.simple
    EOF

    echo "Plotting karyotype -> ${species1}.${species2}.karyotype.pdf"
    python -m jcvi.graphics.karyotype --basepair --diverge Spectral --style white --chrstyle roundrect -o ${species1}.${species2}.karyotype.pdf seqids layout
    """

    output:
    path "${species1}.${species2}.karyotype.pdf", emit: karyotype_pdf
    path "${species1}.${species2}.anchors.simple", emit: anchors_simple
    path "${species1}.${species2}.anchors", emit: anchors_raw
    tuple val('jcvi'), eval("python -m jcvi.graphics.karyotype --help | sed '\$!d; s/.*libraries //;s/ .*//'"), topic: versions
}
