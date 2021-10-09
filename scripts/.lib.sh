#!/usr/bin/env bash

##############################################################################
#    DESCRIPTION: Library of methods specifically for the project.
#    Include using source .whales/.lib.sh
##############################################################################

source scripts/.lib.globals.sh;
source scripts/.lib.utils.sh;

##############################################################################
# GLOBAL VARIABLES
##############################################################################

env_from ".env" import REQUIREMENTS_PY;
env_from ".env" import NAME_OF_APP;

export CONFIGENV="data/.env";
export PYTHON_APP_PREFIX=\
'''#!/usr/bin/env python3
# -*- coding: utf-8 -*-'''
export USE_VENV=false;

##############################################################################
# AUXILIARY METHODS: Zip
##############################################################################

function create_zip_archive() {
    zip -r $@;
}

##############################################################################
# AUXILIARY METHODS: Python
##############################################################################

function use_python_venv_true() { USE_VENV=true; }
function use_python_venv_false() { USE_VENV=false; }

function create_python_venv() {
    ! ( $USE_VENV ) && return;
    _log_info "Create VENV";
    ! [ -d build ] && mkdir build;
    pushd build >> $VERBOSE;
        call_python -m venv env;
    popd >> $VERBOSE;
}

function activate_python_venv() {
    ! ( $USE_VENV ) && return;
    if ( is_linux ); then
        source build/env/bin/activate;
    else
        source build/env/Scripts/activate;
    fi
}

function deactivate_python_venv() {
    ! ( $USE_VENV ) && return;
    if ( is_linux ); then
        source build/env/bin/deactivate;
    else
        source build/env/Scripts/deactivate;
    fi
}

function call_python() {
    if ( is_linux ); then
        python3 $@;
    else
        py -3 $@;
    fi
}

function call_v_python() { activate_python_venv && call_python $@; }

function call_utest() { call_python -m unittest discover $@; }

function call_v_utest() { activate_python_venv && call_utest $@; }

function call_pipinstall() {
    # Do not use --user flag with venv
    DISPLAY= && call_python -m pip install $@;
}

function install_requirements_python() {
    local path="$1";
    local has_problems=false;
    local problem_packages=();

    dos_to_unix "$path";
    local line;
    while read line; do
        line="$( _trim_trailing_comments "$line" )";
        [ "$line" == "" ] && continue;
        _log_info "Run \033[92;1mPIP\033[0m to install \033[93;1m$line\033[0m...";
        ( call_pipinstall "$line" ) && continue;
        has_problems=true;
        problem_packages+=( "$line" );
    done <<< "$( cat "$path" )";

    ( $has_problems ) && _log_fail "Something went wrong whilst using \033[92;1mPIP\033[0m to install: {\033[93;1m${problem_packages[*]}\033[0m}.";
}

function install_requirements_v_python() { activate_python_venv && install_requirements_python $@; }

##############################################################################
# AUXILIARY METHODS: APT-GET
##############################################################################

function run_install_apt() {
    apt-get install -y $@;
}

function install_requirements_aptget() {
    local path="$1";
    local has_problems=false;
    local problem_packages=();

    local line;
    while read line; do
        line="$( _trim_trailing_comments "$line" )";
        [ "$line" == "" ] && continue;
        _log_info "Run \033[92;1mAPT-GET\033[0m install \033[93;1m$line\033[0m...";
        ( run_install_apt "$line" >> $VERBOSE ) && continue;
        has_problems=true;
        problem_packages+=( "$line" );
    done <<< "$( cat "$path" )";

    ( $has_problems ) && _log_fail "Something went wrong whilst using \033[92;1mAPT-GET\033[0m to install: {\033[93;1m${problem_packages[*]}\033[0m}.";
}

##############################################################################
# AUXILIARY METHODS: CLEANING
##############################################################################

function garbage_collection_build() {
    clean_folder_contents "build";
}

function garbage_collection_python() {
    clean_all_folders_of_pattern ".DS_Store";
    local path;
    for path in "src" "test"; do
        pushd "$path" >> $VERBOSE;
            # clean_all_files_of_pattern "*\.pyo";
            clean_all_folders_of_pattern "__pycache__";
        popd >> $VERBOSE;
    done
}

function garbage_collection_dist() {
    remove_file "dist/$NAME_OF_APP";
}

##############################################################################
# MAIN METHODS: PROCESSES
##############################################################################

function run_display_version() {
    local version="$( cat dist/VERSION )";
    [ "$version" == "" ] && version="---";
    echo "$version";
}

function run_setup() {
    _log_info "RUN SETUP";
    create_python_venv;
    _log_info "Check and install missing requirements";
    install_requirements_v_python "$REQUIREMENTS_PY";
}

function run_create_textartefact() {
    local path="dist/artefact.txt";
    [ -f "$path" ] && rm "$path";
    touch $path;
    echo "Content line 0" >> $path;
    echo "Content line 1" >> $path;
    echo "" >> $path;
    echo "Content line 3" >> $path;
}

function run_create_artefact() {
    local current_dir="$PWD";
    ## create temp artefacts:
    local _temp="$( create_temporary_dir "dist" )";
    copy_dir dir="src" from="." to="$_temp";
    copy_file file="VERSION" from="dist" to="${_temp}/src/setup";
    mv "${_temp}/src/__main__.py" "$_temp";
    ## zip source files to single file and make executable:
    pushd "$_temp" >> $VERBOSE;
        create_zip_archive -o "$current_dir/dist/app.zip" * -x '*__pycache__/*' -x '*.DS_Store';
    popd >> $VERBOSE;
    echo  "$PYTHON_APP_PREFIX" | cat - dist/app.zip > dist/$NAME_OF_APP;
    chmod +x "dist/$NAME_OF_APP";
    ## remove temp artefacts:
    remove_dir "$_temp";
    remove_file "dist/app.zip";
}
