
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}\u2A2F"
ZSH_THEME_GIT_PROMPT_CLEAN=" \u2713"

function directory_name {
    PROMPT_PATH=""

    CURRENT=`dirname ${PWD}`
    if [[ $CURRENT = / ]]; then
        PROMPT_PATH=""
    elif [[ $PWD = $HOME ]]; then
        PROMPT_PATH=""
    else
        if [[ -d $(git rev-parse --show-toplevel 2>/dev/null) ]]; then
            # We're in a git repo.
            BASE=$(basename $(git rev-parse --show-toplevel))
            if [[ $PWD = $(git rev-parse --show-toplevel) ]]; then
                # We're in the root.
                PROMPT_PATH="%{$fg_bold[blue]%}"
            else
                # We're not in the root. Display the git repo root.
                GIT_ROOT="%{$fg_bold[blue]%}${BASE}%{$reset_color%}"

                PATH_TO_CURRENT="${PWD#$(git rev-parse --show-toplevel)}"
                PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"

                PROMPT_PATH="${GIT_ROOT}${PATH_TO_CURRENT}/"
            fi
        else
            PROMPT_PATH=$(print -P %3~)
            PROMPT_PATH="${PROMPT_PATH%/*}/"
        fi
    fi

    echo "${PROMPT_PATH}%1~%{$reset_color%}"
}

function prompt_char {
	if [ $UID -eq 0 ]; then echo "%{$fg[red]%}#%{$reset_color%}"; else echo $; fi
}

PROMPT='%(?,,%{$fg[red]%}FAIL%{$reset_color%}\n\n)%{$FG[237]%}%*%{$reset_color%} $(directory_name)$(git_prompt_info) $(prompt_char) '
