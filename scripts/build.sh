#!/usr/bin/env bash

##############################################################################
#    DESCRIPTION: Script for build-processes.
#
#    Usage:
#    ~~~~~~
#    ./build.sh [options]
##############################################################################

SCRIPTARGS="$@";
FLAGS=( $@ );
ME="scripts/build.sh";
SERVICE="prod-service";

source scripts/.lib.sh;

mode="$( get_one_kwarg_space "$SCRIPTARGS" "-+mode" "" )";
option_venv="$( get_one_kwarg_space "$SCRIPTARGS" "-+venv" "true" )";
( $option_venv ) && use_python_venv_true || use_python_venv_false;

if [ "$mode" == "version" ]; then
    run_display_version;
    exit 0;
elif [ "$mode" == "setup" ]; then
    run_setup;
    exit 0;
elif [ "$mode" == "dist-text" ]; then
    run_create_textartefact;
    exit 0;
elif [ "$mode" == "dist" ]; then
    run_create_artefact;
    exit 0;
else
    _log_error "Invalid argument to build script!";
    _cli_message "Call ./scripts/build.sh [--venv [true|false]] --mode [version|setup|dist|dist-text].";
    exit 1;
fi
