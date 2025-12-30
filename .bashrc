DOTFILES_DIRNAME=$(realpath -- "$(dirname "${BASH_SOURCE}")")

# https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
append_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

prepend_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

# Useful 'stronger' sudo 
psudo() {
    sudo -E LD_LIBRARY_PATH="$LD_LIBRARY_PATH" "$@"
}

# Colored man pages https://www.tecmint.com/view-colored-man-pages-in-linux/
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# check for completions for shopt using `compgen -A shopt`
shopt -s globstar

prepend_path "$HOME"/bin
prepend_path .

PS0='\[\e[2 q\]' # reset cursor (we need this or it would mess up program cursors especially vim)
PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '


export EDITOR=vim

export DOTFILES_RED="\033[0;31m"
export DOTFILES_YELLOW="\033[1;33m"
export DOTFILES_GREEN="\033[1;32m"
export DOTFILES_BLUE="\033[1;34m"
export DOTFILES_CYAN="\033[1;36m"
export DOTFILES_LIGHT_GREEN="\033[1;32m"
export DOTFILES_WHITE="\033[1;37m"
export DOTFILES_LIGHT_GRAY="\033[0;37m"
export DOTFILES_COLOR_NONE="\e[0m"

function dotfiles_set_exit_code()
{
    DOTFILES_EXIT_CODE=""
    if [[ $DOTFILES_RETVAL != 0 ]]
    then
        DOTFILES_EXIT_CODE="\[${DOTFILES_RED}\]Err(${DOTFILES_RETVAL}) \[${DOTFILES_COLOR_NONE}\]"
    fi
}
export -f dotfiles_set_exit_code

function dotfiles_set_virtualenv()
{
    if [[ -n "$VIRTUAL_ENV_PROMPT" ]]
    then
        PYTHON_VIRTUALENV="\[${DOTFILES_BLUE}\]$VIRTUAL_ENV_PROMPT\[${DOTFILES_COLOR_NONE}\]"
    elif [[ -n "$VIRTUAL_ENV" ]]
    then
        case "$VIRTUAL_ENV" in
        *venv)
            PYTHON_VIRTUALENV="\[${DOTFILES_BLUE}\][$(basename -- "$(dirname -- "$VIRTUAL_ENV")")]\[${DOTFILES_COLOR_NONE}\]"
            ;;
        *)
            PYTHON_VIRTUALENV="\[${DOTFILES_BLUE}\][$(basename "$VIRTUAL_ENV")]\[${DOTFILES_COLOR_NONE}\]"
            ;;
        esac
    else
        PYTHON_VIRTUALENV=""
    fi
}
export -f dotfiles_set_virtualenv

function fzf_history_search()
{
    local selected_command
    selected_command=$(awk '!/^ *#/{print $0}' ~/.bash_history \
        | tac \
        | awk '!a[$0]++' \
        | tail -n 10000 \
        | fzf --exact +s --sync -q "$READLINE_LINE"
    )
    if [[ -n "$selected_command" ]]
    then
        READLINE_LINE=$selected_command
        READLINE_POINT=${#selected_command}
    fi
}

if [[ $- == *i* ]]
then
    if command -v fzf &>/dev/null
    then
        bind -x '"\C-r": fzf_history_search'
    fi
fi

function dotfiles_bind_tmux_on_off()
{
    if [[ -n "$TMUX" && ("$TERM" == screen* || "$TERM" == tmux*) ]]
    then
        if [[ "$(tmux display-message -p '#{session_name}')" = mysession ]]
        then
            tmux kill-session
        fi 
    else
        tmux new-session -A -s mysession
    fi
}

function dotfiles_autocomplete_completion_func_code()
{
    local completion_command=$1
    local cur_word=$2
    local prev_word=$3

    case "$prev_word" in
    -a|--add|-g|--goto)
        compopt -o nospace
        COMPREPLY=($(compgen -f "$cur_word"))
        ;;
    *)
        COMPREPLY=(
            -d --diff
            -m --merge
            -a --add
            -g --goto
            -n --new-window
            -r --reuse-window
            -w --wait
            -h --help
            --list-extensions
            --show-versions
            --category
            --install-extension
            --uninstall-extension
            --update-extensions
            -v --version
            --verbose
            -s --status
        )
        ;;
    esac
    COMPREPLY=($(compgen -W "${COMPREPLY[*]}" -- "$cur_word"))
}

function dotfiles_bu_activate()
{
    if [[ ! -e "$DOTFILES_DIRNAME"/deps/bash-utils ]]
    then
        echo bash-utils not found >&2
        return 1
    fi

    if [[ "$BU_MODULE_PATH" != */dotfiles_bu_module.sh* ]]
    then
        BU_MODULE_PATH+=:$DOTFILES_DIRNAME/dotfiles_bu_module.sh
    fi
    # shellcheck source=./deps/bash-utils/bu_entrypoint.sh
    source "$DOTFILES_DIRNAME"/deps/bash-utils/bu_entrypoint.sh
}

function dotfiles_set_bash_prompt()
{
    DOTFILES_RETVAL=$?

    history -a

    dotfiles_set_exit_code
    dotfiles_set_virtualenv

    local git_branch=$(git rev-parse --abbrev-ref @ 2>/dev/null)
    local remote_git_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)
    local username_color=${BU_TPUT_VSCODE_BLUE:-$DOTFILES_CYAN}
    local host_color=${BU_TPUT_VSCODE_GREEN:-$DOTFILES_GREEN}
    local cwd_color=${BU_TPUT_VSCODE_ORANGE:-$DOTFILES_CYAN}
    local git_branch_color=${BU_TPUT_VSCODE_GREEN:-$DOTFILES_GREEN}
    local remote_git_branch_color=${BU_TPUT_VSCODE_DARK_GREEN:-$DOTFILES_GREEN}
    local prompt_color=${BU_TPUT_VSCODE_YELLOW:-$DOTFILES_YELLOW}
    local reset=${BU_TPUT_RESET:-$DOTFILES_COLOR_NONE}
    if [[ -n "$git_branch" ]]
    then
        git_branch=" (\[${git_branch_color}\]$git_branch\[${reset}\]${remote_git_branch:+->}\[${remote_git_branch_color}\]${remote_git_branch}\[${reset}\])"
    fi

    PS1="${DOTFILES_EXIT_CODE}${PYTHON_VIRTUALENV}\[${username_color}\]\u\[${reset}\]@\[${host_color}\]\h\[${reset}\]:\[${cwd_color}\]\w\[${reset}\]${git_branch}\n\[${prompt_color}\]\\\$ \[${reset}\]"
}

export -f dotfiles_set_bash_prompt
export PROMPT_COMMAND=dotfiles_set_bash_prompt

if [[ ! -e "$DOTFILES_DIRNAME"/deps/LS_COLORS ]]
then
    git -C "$DOTFILES_DIRNAME" submodule update --init
fi

if [[ ! -e "$HOME"/.lscolors.sh ]]
then
    sort "$DOTFILES_DIRNAME"/deps/LS_COLORS/LS_COLORS | dircolors --bourne-shell - > "$HOME"/lscolors.sh
fi

source "$HOME"/lscolors.sh

cd "$HOME"
# Tbh this is a bit overkill, also it disrupts the other environments a bit
# dotfiles_bu_activate


complete -F dotfiles_autocomplete_completion_func_code code
bind -x '"\et": "dotfiles_bind_tmux_on_off"'
