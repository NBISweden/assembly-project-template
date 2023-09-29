# Custom code folder

Place custom code used in your analysis here, and use a launch script in the `analysis` folder
to run it. 

e.g., in `analyses/02_custom-script_rackham/run_bash.sh`:

```bash
#! /usr/bin/env bash

# Path to where custom code is placed
SCRIPT_DIR=../../code/scripts/

# Clean up data/intermediates
...

# Run custom code
$SCRIPT_DIR/my_custom_script.sh parameters.txt configuration.txt

# Clean up work directories.

```

and `my_custom_script.sh` looks like:

```bash
#! /usr/bin/env bash

PARAMS=${1:-""}
CONFIG=${2:-""}
SINGULARITY_CACHEDIR="${STORAGEALLOC}/nobackup/ebp-singularity-cache"

singularity exec $SINGULARITY_CACHEDIR/tool.sif tool < $PARAMS
```
