# TASK 1 - Write a shell script that checks the disk usage in a given directory:
* The script can take two optional arguments and one compulsory argument...
* -d: Which means that all files and directory within the specified directory or directories should be listed.
* -n: Which means that the top N enteries should be returned. Where N is an integer.
* List of directories: This will be the directories you want to check it's disk usage

> e.g: ` yourscript.sh -d -n 10 /etc ` should return the top 10 files & directories disk usage in /etc directory

> Note: When the -n argument is not given your script -`yourscript.sh -d /etc` will return the default top 8 files & directories disk usage in /etc directory

## SOLUTION:
```
#!/bin/bash

# define variables
display_files=false
default_entries=8
optstrings="dn:"

#help function
help() {
    echo "Usage: $0 [-d -n N] directory"
    echo "Where N is an integer"
}

#case statment for various options and arguments
while getopts "${optstrings}" opt;
do 
    case $opt in 
        d) 
          show_files=true
        ;;
        n) 
          default_entries=$OPTARG
        ;;
        \?) 
          help
        ;;
    esac
done

shift "$((OPTIND - 1))"

#loop through different directories and default_entries
for dir in "$@"; do
    if [ ! -d $dir ]; then
        echo "***********************************"
        echo "$dir is not a valid directory"
        continue
    fi

    if [ $display_files=true ]; then
        out_put=$(sudo find "$dir" -type f -exec du -Sh {} + | sort -rh | head -n "$default_entries")
    else 
        out_put=$(du -h "$dir" 2>/dev/null | sort -rh | head -n "$default_entries")

    fi

    echo "****************************************"
    echo "$out_put"
    echo "****************************************"

done
# sudo find /etc -type f -exec du -Sh {} + | sort -rh | head -n 5
# du -h /etc 2>/dev/null | sort -rh | head -n 5

```








