#!/usr/bin/env bash

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
cd "$SCRIPT_DIR" || exit 1

append_source_file() {
    local source_keyword
    source_keyword=$1
    local src_filepath # relative
    src_filepath=$2
    local dest_filepath # relative to $HOME, can be a directory as well
    dest_filepath=${3:-${src_filepath}}
    echo "$source_keyword"' '"${SCRIPT_DIR}"/"$src_filepath" >> "$HOME"/"$dest_filepath"
}

append_sh_source_file() {
    local src_filepath # relative
    src_filepath=$1
    local dest_filepath # relative to $HOME
    dest_filepath=${2:-${src_filepath}}
    if ! test -e "$HOME"/"$dest_filepath"; then
        echo '#!/usr/bin/env bash' >> "$HOME"/"$dest_filepath"
        chmod +x "$HOME"/"$dest_filepath"
    fi
    append_source_file . "$src_filepath" "$dest_filepath" 
}

gdbinit_install() {
    local gdbinit
    gdbinit=.config/gdb/gdbinit
    if test -e "$HOME"/.gdbinit; then
        gdbinit=.gdbinit
    fi
    mkdir -p "$(dirname "$HOME"/"$gdbinit")"
    append_source_file source .gdbinit "$gdbinit"
}
