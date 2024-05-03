#!/bin/bash

directory="/home/user/Private"

if [ -d "$directory" ]; then
  [ -z "$(ls -A "$directory")" ]; then
    gio trash "$directory"
fi
