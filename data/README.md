# README

Data stored in this folder should not be tracked with Git. The only
parts that are intended to be tracked are the top-level folder structure,
and specific files.

```
/data
    | - deliveries    (data deliveries moved from INBOX and made read-only)
    | - raw-data      (subfolders named after library-type, symlinked to files in deliveries, managed by a script for data integrity)
    | - intermediates (workflow/script outputs from exploratory phase)
    \ - finalized     (symlinked folders to `intermediates` marking assembly phase end-points)
```
