#! /usr/bin/env bash

## Usage
## 
## Supply paths to raw data in LINKS array below
## Run this script ./update-link-data.sh
## Git commit changes and push to repository.

declare -A links=( )
links["library-type/filename"]='/path/to/delivery/file'

for symlink in "${!links[@]}"; do
    source="${links[$symlink]}"
    mkdir -p $( dirname "$source" )
    test -f "$symlink" || \
        ( test -f "$source" && \
        ln -s "$source" "$symlink" ) || \
        echo "$source does not exist. Check for a mistyped path".
done
