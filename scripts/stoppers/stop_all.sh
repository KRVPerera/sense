#!/usr/bin/env bash

# Store the name of the current script
CURRENT_SCRIPT=$(basename "$0")

# Navigate to the directory
cd $SENSE_STOPPERS_HOME

for script in *.sh; do
    # Skip the script if it is the current script
    if [ "$script" != "$CURRENT_SCRIPT" ]; then
        echo "Running $script"
        bash "$script"

        # Delete the script after running
        echo "Deleting $script"
        rm "$script"
    fi
done