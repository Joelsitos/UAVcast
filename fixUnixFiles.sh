#!/usr/bin/env bash

_unwindows() {

    local errmsg;
    local filepath;

    # base case
    errmsg="$(git add . 2>&1)";
    if [ $? -eq 0 ]; then
        echo "Successfully converted CRLF to LF in all files.";
        echo "Successfully ran `git add .`.";
        echo "Done.";
        return 0;
    fi;

    filepath="${errmsg#*fatal: CRLF would be replaced by LF in }";
    filepath="${filepath%.*}";
    if [ "${filepath}" = "${errmsg}" ]; then
        echo "Regex failed. Could not auto-generate filename from stderr.";
        return 1;
    fi;

    if [ ! -e "${filepath}" ]; then
        echo "Regex failed. '${filepath}' does not exist.";
        return 1;
    fi;

    dos2unix "${filepath}";
    if [ $? -ne 0 ]; then
        echo "Failed to run \`dos2unix '${filepath}'\`.";
        return 1;
    fi;

    # recursive case
    _unwindows;
};

_unwindows;
