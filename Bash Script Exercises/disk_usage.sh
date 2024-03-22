#!/bin/bash

# define variables
display_files=false
default_entries=8
optstrings="dn:"

#help function
help() {
    echo "Usage: $0 [-d -n N] directory"
    echo "Where N is an integer"
    exit 1
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