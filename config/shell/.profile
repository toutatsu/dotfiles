[[ $- == *i* ]] && echo loading dotfiles/.profile ... || echo 'non-interactive' > /dev/null


export EDITOR=vim

### ssh ###

# SSH Agent のプロセスIDを取得
agent_pid=$(pgrep ssh-agent)

# SSH Agent が起動していない場合、起動する
if [ -z "$agent_pid" ]; then
  eval "$(ssh-agent -s)"
fi

# SSH 鍵が登録されていない場合、登録する
if ! ssh-add -l >/dev/null 2>&1; then
  ssh-add
fi


trash(){
  mv -i $@ ~/.Trash && echo "\`$@\` is moved to ~/.Trash"
}

# alias rm=trash
