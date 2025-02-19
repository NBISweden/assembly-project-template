# Checklist

- [ ] I'm using the latest version of the [assembly project template](https://github.com/NBISweden/assembly-project-template)

## Read data

- [ ] All data delivered to us for the analysis are read-only in the folder `data/deliveries`.
- [ ] The data used in the assembly are symlinked under `data/raw-data`.
- [ ] Read metadata has also been received.

## Analyses

- [ ] All code necessary to create the final assembly is under `analyses` or `code`.
- [ ] The file `analyses/History.md` has a step by step description of how to use the read data to make the submitted assembly.
- [ ] The final output is in the folder `data/frozen`.
- [ ] The final assembly has been discussed with the team.

## Assembly

PacBio reads used for assembly:
```
/path/to/PacBio/reads
```

Hi-C reads used for assembly:
```
/path/to/Hi-C/reads
```

Assembly:
```
/path/to/assembly/for/submission
```

- [ ] An [EAR report](https://github.com/ERGA-consortium/EARs) has been made.
- [ ] The data stewards have been given the path to the finished assembly.
- [ ] The paths to all data used in the assembly is recorded above in this file.

## Project completion

- [ ] Raw data has been uploaded to/published in a(n external) repository.
- [ ] PI has been offered/reminded to download raw data locally, and has responded.
- [ ] All data have been checked to be in the latest version, and updates (e.g. to an assembly) have been made when applicable.
- [ ] Removal decision has been made and approved by all parties (NBIS and PI).
- [ ] This repository is up to date, and all necessary files have been checked in and pushed to Github.
- [ ] Intermediate and temporary analysis files have been removed.
- [ ] Data has been removed.

Data accession list:

| Data type | Accession |
|-----------|-----------|
| PacBio    |           |
| HiC       |           |
| Assembly  |           |
