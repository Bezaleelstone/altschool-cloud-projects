#!/bin/bash

#Define variables for arguments passed
src=$1
destination=$2

#create time stamp
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

#Check if source argument passed is a directory
if [ -z $src ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
elif [ ! -d $src ]; then
    echo " <$1> not a valid directory"
    exit 1
fi

#Create destination directory if it doesn't exist
if [ ! -d $destination ]; then
    mkdir -p "$destination"
fi

echo "Backup in progress...."

sleep 3

tar -czf "$destination/$2_backup_$timestamp.tar.gz" "$src" 2>/dev/null

echo "Backup successful"

echo "*******************************"



