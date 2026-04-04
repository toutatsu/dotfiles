[[ $- == *i* ]] && echo loading dotfiles/.zshrc ... || echo 'non-interactive' > /dev/null

source ~/.profile

### oh-my-zsh ###
# https://ohmyz.sh/
# https://github.com/ohmyzsh/ohmyzsh

# install
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="mytheme"

# ランダムテーマ選択用: ZSH_THEME="random" と組み合わせる
# ZSH_THEME_RANDOM_CANDIDATES=(
#   "rkj"
#   "candy-kingdom"
# )
# ZSH_THEME_RANDOM_IGNORED=()  # ランダム選択から除外するテーマ

# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins-Overview
plugins=(
  git
  vi-mode
  themes
)

source $ZSH/oh-my-zsh.sh

#################


# autoload : load function in $FPATH
# refer zshbuiltins for more details


# completion
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit


# colors
autoload -Uz colors && colors


# history-search
# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#History-Control
autoload -U history-search-end

bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_all_dups
setopt share_history

# インクリメンタル履歴検索 (^R/^S) と前後サーチ (^P/^N) の代替バインド
#bindkey '^R' history-incremental-search-backward
#bindkey '^S' history-incremental-search-forward
#bindkey '^P' history-beginning-search-backward
#bindkey '^N' history-beginning-search-forward


# hook
# add-zsh-hook は oh-my-zsh が autoload 済み (手動 autoload 不要)
# add-zsh-hook preexec my_preexec  # 下枠は mytheme の PROMPT 内で描画するため不要
add-zsh-hook precmd my_precmd  # 次プロンプト表示前に下枠を描画

_first_prompt=true
my_precmd() {
    if [[ $_first_prompt == true ]]; then
        _first_prompt=false  # 初回はスキップ (閉じる枠がないため)
    else
        printf "${reset_color}╚"
        printf '═%.0s' $(seq 3 $COLUMNS)
        printf "╝\n"
    fi
}

# my_preexec() {
#     printf "${reset_color}"
#     echo -n "╚"
#     printf '═%.0s' $(seq 3 $(tput cols))
#     echo "╝"
# }

# Enter 時に cursor magic で描いた下枠を消去 (コマンド出力との混在を防ぐ)
zle-line-finish() {
    print -n $'\e[1B\r\e[2K\e[1A'
}
zle -N zle-line-finish

# prompt (oh-my-zsh テーマ不使用時の手動定義)
# PROMPT="${fg[magenta]}Zsh ${fg[green]}%n${reset_color}@${fg[cyan]}%M${reset_color}:${fg[yellow]}%~ ${reset_color}[ %D %* ]
# $ ${fg[yellow]}"


# vi
# set -o vi  # readline ベースの vi モード (.inputrc で設定済みのため通常不要)

# show vi mode in prompt using zle(zsh line editor)
# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
# function update-prompt-vi {

#     # PROMPT="${fg[magenta]}Zsh ${fg[green]}%n${reset_color}@${fg[cyan]}%M${reset_color}:${fg[yellow]}%~ ${reset_color}[ %D %* ] ${fg[white]}${bg[cyan]}⎇ $vcs_info_msg_0_${reset_color} "
        
#     case $KEYMAP in
#         vicmd)
# # PROMPT=$PROMPT"%{$fg_bold[green]%}CMD%{$reset_color%}
# # $ ${fg[yellow]}"
#         ;;
#         main|viins)
# # PROMPT=$PROMPT"%{$fg_bold[green]%}INS%{$reset_color%}
# # $ ${fg[yellow]}"
#         ;;
#     esac

#     # echo ""
#     zle reset-prompt
# }

# called after Enter
# function zle-line-init { 
#     update-prompt-vi;
#     # echo '\n\nzle-line-init\n\n';
# }
# zle -N zle-line-init

# called when vi mode is switched
# function zle-keymap-select { 
#     update-prompt-vi;
#     # echo '\n\nzle-keymap-select\n\n';
# }
# zle -N zle-keymap-select


# git (zsh 組み込みの vcs_info でブランチ名等をプロンプトに表示する)
# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh
# autoload -Uz vcs_info
# precmd_vcs_info() { vcs_info }
# precmd_functions+=( precmd_vcs_info )
# setopt prompt_subst
# RPROMPT=\$vcs_info_msg_0_
# PROMPT=\$vcs_info_msg_0_'%# '
# zstyle ':vcs_info:git:*' formats '%b'


# alias
# alias l="ls -BFGOPTWaelhis"  # macOS 拡張オプション付き (BSD ls 向け)
alias l="ls -BFGalhis"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# vcs_info フック: クリーン状態と未追跡ファイルをプロンプトに表示する (上の git ブロックと組み合わせる)
# zstyle ':vcs_info:git+set-message:*' hooks git-is_clean git-untracked
# # 状態がクリーンか判定
# function +vi-git-is_clean(){
#     if [ -z "$(git status --short 2>/dev/null)" ];then
#         hook_com[misc]+="✔"
#     fi
# }
# # unstaged, untrackedの検知
# function +vi-git-untracked() {
#     if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
#         hook_com[unstaged]+='%F{red}✗%f'
#     fi
# }
