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
  # 通常環境: 固定ソケットパスで ssh-agent を管理する
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

  ssh-add -l >/dev/null 2>&1
  _ssh_status=$?

  if [ $_ssh_status -eq 2 ]; then
    # エージェント未起動またはソケットが無効 → 再起動
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
    echo 'ssh-agent started.'
    ssh-add
  elif [ $_ssh_status -eq 1 ]; then
    # エージェントは動いているが鍵未登録
    ssh-add
  fi

  unset _ssh_status
fi


trash(){
  mv -i $@ ~/.Trash && echo "\`$@\` is moved to ~/.Trash"
}

# alias rm=trash
