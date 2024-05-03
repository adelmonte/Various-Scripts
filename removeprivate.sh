#!/bin/bash

directory="/home/user/Private"

if [ -d "$directory" ]; then
  if [ -z "$(ls -A "$directory")" ]; then
    gio trash "$directory"
    echo "Empty directory 'Private' moved to trash."
  else
    echo "Directory 'Private' contains files. Skipping deletion."
  fi
else
  echo "Directory 'Private' does not exist."
fi
