#!/usr/bin/env bash

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

export SENSE_HOME="${HOME}/sense"

# Change directory to ~/shared
if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
    TARGET_DIR="${SENSE_HOME}/scripts"
    SCRIPTS=scripts
    # Check if the symbolic link does not exist
    if [ ! -L "${HOME}/shared/$SCRIPTS" ]; then
        # Create the symbolic link
        mkdir -p "${HOME}/shared/${SCRIPTS}"
        ln -s "$TARGET_DIR" "${HOME}/shared/${SCRIPTS}"
    fi
fi



if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
    export SENSE_SCRIPTS_HOME="${HOME}/shared/${SCRIPTS}"
    export SENSE_STOPPERS_HOME="${SENSE_SCRIPTS_HOME}/stoppers"
    export SENSE_FIRMWARE_HOME="${HOME}/shared/firmware"
else
    export SENSE_SCRIPTS_HOME="${SENSE_HOME}/${SCRIPTS}"
    export SENSE_STOPPERS_HOME="${SENSE_SCRIPTS_HOME}/stoppers"
    export SENSE_FIRMWARE_HOME="${HOME}/bin"
fi

if [ ! -d "$SENSE_FIRMWARE_HOME" ]; then
    mkdir -p "$SENSE_FIRMWARE_HOME"
fi