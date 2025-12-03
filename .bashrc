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

RED="\[\033[0;31m\]"
YELLOW="\[\033[1;33m\]"
GREEN="\[\033[1;32m\]"
BLUE="\[\033[1;34m\]"
CYAN="\[\033[1;36m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
COLOR_NONE="\[\e[0m\]"

function set_exit_code()
{
    EXIT_CODE=""
    if [[ $RETVAL != 0 ]]
    then
        EXIT_CODE="${RED}Err(${RETVAL}) ${COLOR_NONE}"
    fi
}

function set_virtualenv()
{
    if [[ -n "$VIRTUAL_ENV_PROMPT" ]]
    then
        PYTHON_VIRTUALENV="${BLUE}$VIRTUAL_ENV_PROMPT${COLOR_NONE}"
    elif [[ -n "$VIRTUAL_ENV" ]]
    then
        case "$VIRTUAL_ENV" in
        *venv)
            PYTHON_VIRTUALENV="${BLUE}[$(basename -- "$(dirname -- "$VIRTUAL_ENV")")]${COLOR_NONE}"
            ;;
        *)
            PYTHON_VIRTUALENV="${BLUE}[$(basename "$VIRTUAL_ENV")]${COLOR_NONE}"
            ;;
        esac
    else
        PYTHON_VIRTUALENV=""
    fi
}

function set_bash_prompt()
{
    RETVAL=$?

    history -a
    set_exit_code
    set_virtualenv

    local git_branch=$(git rev-parse --abbrev-ref @ 2>/dev/null)
    local remote_git_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)
    if [[ -n "$git_branch" ]]
    then
        git_branch=" ($git_branch${remote_git_branch:+->}${remote_git_branch})"
    fi

    PS1="${EXIT_CODE}${PYTHON_VIRTUALENV}${CYAN}\u${COLOR_NONE}@${GREEN}\h${COLOR_NONE}:\w${git_branch}\n${YELLOW}\\\$ ${COLOR_NONE}"
}
export PROMPT_COMMAND=set_bash_prompt

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

function bu_activate()
{
    if [[ ! -e ~/Documents/shell-utils ]]
    then
        echo shell-utils not found >&2
        return 1
    fi
    source ~/Documents/shell-utils/bu_entrypoint.sh
}
