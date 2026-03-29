[[ $- == *i* ]] && echo loading dotfiles/.bash_profile ...

# ログインシェルでも .bashrc の設定を読み込む
[[ -f ~/.bashrc ]] && source ~/.bashrc
