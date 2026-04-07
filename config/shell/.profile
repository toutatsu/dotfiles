[[ $- == *i* ]] && echo loading dotfiles/.profile ... || echo 'non-interactive' > /dev/null


export EDITOR=vim

# User-local binaries (e.g. Claude Code, pip-installed tools)
export PATH="$HOME/.local/bin:$PATH"

### ssh ###

if [ -n "$TERMUX_VERSION" ]; then
  # Termux: termux-services で管理される ssh-agent サービスのソケットを参照
  # 事前に: pkg install termux-services && sv-enable ssh-agent
  export SSH_AUTH_SOCK="$PREFIX/tmp/ssh-agent.socket"
else
  # 通常環境: ssh-agent が起動していなければ起動する
  agent_pid=$(pgrep ssh-agent)
  if [ -z "$agent_pid" ]; then
    eval "$(ssh-agent -s)"
    echo 'ssh-agent started.'
  fi

  # SSH 鍵が登録されていない場合、登録する
  if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add
  fi
fi


trash(){
  mv -i $@ ~/.Trash && echo "\`$@\` is moved to ~/.Trash"
}

# alias rm=trash
