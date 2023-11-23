#!/usr/bin/env bash

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

export SENSE_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "SENSE_HOME is set to $SENSE_HOME"

SCRIPTS=scripts

export SENSE_FIRMWARE_HOME="${SENSE_HOME}/bin"


if [ ! -d "$SENSE_FIRMWARE_HOME" ]; then
    mkdir -p "$SENSE_FIRMWARE_HOME"
fi

TARGET_DIR="${SENSE_HOME}/scripts"
ln -s "$TARGET_DIR" "${SENSE_FIRMWARE_HOME}"

export SENSE_SCRIPTS_HOME="${SENSE_FIRMWARE_HOME}/${SCRIPTS}"
export SENSE_STOPPERS_HOME="${SENSE_SCRIPTS_HOME}/stoppers"

if [ ! -d "$SENSE_SCRIPTS_HOME" ]; then
    mkdir -p "$SENSE_SCRIPTS_HOME"
fi

if [ ! -d "$SENSE_STOPPERS_HOME" ]; then
    mkdir -p "$SENSE_STOPPERS_HOME"
fi
