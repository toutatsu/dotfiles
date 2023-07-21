# autoload : load function in $FPATH
# for more detail, refer zshbuiltins.

# completion
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit

# colors
autoload -Uz colors && colors

# hook
autoload -Uz add-zsh-hook
add-zsh-hook preexec my_preexec
add-zsh-hook precmd my_precmd

my_precmd() {
}

my_preexec() {
    printf "${reset_color}"
}

# prompt
PROMPT="${fg[magenta]}Zsh ${fg[green]}%n${reset_color}@${fg[cyan]}%M${reset_color}:${fg[yellow]}%~ ${reset_color}[ %D %* ]
$ ${fg[yellow]}"

# vi
set -o vi

# show vi mode using zle(zsh line editor)
function zle-line-init zle-keymap-select {
    PROMPT="${fg[magenta]}Zsh ${fg[green]}%n${reset_color}@${fg[cyan]}%M${reset_color}:${fg[yellow]}%~ ${reset_color}[ %D %* ] ${fg[white]}${bg[cyan]}$vcs_info_msg_0_${reset_color} "
    case $KEYMAP in
        vicmd)
        PROMPT=$PROMPT"%{$fg_bold[green]%}CMD%{$reset_color%}
$ ${fg[yellow]}"
        ;;
        main|viins)
        PROMPT=$PROMPT"%{$fg_bold[green]%}INS%{$reset_color%}
$ ${fg[yellow]}"
        ;;
    esac
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# alias
alias l="ls -BFGLOTWaelhis"

# git
# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
# RPROMPT=\$vcs_info_msg_0_
# PROMPT=\$vcs_info_msg_0_'%# '
zstyle ':vcs_info:git:*' formats '%b'
