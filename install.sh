#!/usr/bin/env bash

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
pushd "$SCRIPT_DIR" || exit 1
set -x
echo 'source '"${SCRIPT_DIR}"/.bashrc >> "$HOME"/.bashrc
# shellcheck disable=SC2016
echo '$include '"${SCRIPT_DIR}"/.inputrc >> "$HOME"/.inputrc
echo 'source '"${SCRIPT_DIR}"/.lessfilter >> "$HOME"/.lessfilter
GDBINIT=$HOME/.config/gdb/gdbinit
if test -e "$HOME"/.gdbinit; then
    GDBINIT="$HOME"/.gdbinit
fi
mkdir -p "$(dirname "$GDBINIT")"
echo 'source '"${SCRIPT_DIR}"/.gdbinit >> "$GDBINIT"
ln -s "$(realpath .shellcheckrc)" "$HOME"/.shellcheckrc
echo 'so '"${SCRIPT_DIR}"/.vimrc >> "$HOME"/.vimrc
set +x
popd
