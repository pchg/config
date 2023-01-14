#!/bin/bash
 
function pytest() {
    if [[ "x${VIRTUAL_ENV}" == "x" ]]; then
        # Make sure we're in a Python venv, but don't muck up the user's shell
        (
            pva && pytest
        )
        return $?
    fi
    if [ -f ./setup.py ]; then
        # Run pytest from the module setup script
        python3 ./setup.py pytest
    else
        if [[ "$(pwd)" == '/' ]]; then
            # We've hit root, we can't search further
            echo 'Could not find Python setup file!' >&2
            return 1
        else
            # Go up a directory and retry, but don't muck with the user's shell
            (
                cd ../
                pytest
            )
        fi
    fi
}
 
function pva() {
    # "Python Venv Activate"
    if [ -d "${1}" ]; then
        root="${1}"
    else
        root="$(pwd)"
    fi
 
    if [ -f "${root}/env/bin/activate" ]; then
        . "${root}/env/bin/activate"
    else
        if [[ "${root}" == '/' ]]; then
            # We've hit root, we can't search further
            echo 'Could not find Python venv Activate file!' >&2
            return 1
        else
            pva "$(dirname "${root}")"
        fi
    fi
}
 
function pvc() {
    # Create and activate a new Python venv
 
    version="3"
    if [ $# -eq 1 ]; then
        version="${1}"
    fi
 
    # Deactivate existing first!
    if [ -d "${VIRTUAL_ENV}" ] && type deactivate >/dev/null 2>&1; then
        deactivate
    fi
 
    # Use provided path (if given), then git root, then (finally) current directory
    git_root="$(git rev-parse --show-toplevel)"
    if [ -d "${1}" ]; then
        root="${1}"
    elif [ -d "${git_root}" ]; then
        root="${git_root}"
    else
        root="$(pwd)"
    fi
 
    env_root="${root}/env"
 
    if [ -d "${env_root}" ]; then
        rm -r "${env_root}"
    fi
 
    python"${version}" -m venv "${env_root}"
 
    pva "${root}"
}
 
# vim: ts=4 sts=4 sw=4 expandtab

