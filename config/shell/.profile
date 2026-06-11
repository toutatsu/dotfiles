[[ $- == *i* ]] && echo loading dotfiles/.profile ... || echo 'non-interactive' > /dev/null


export EDITOR=vim

# User-local binaries (e.g. Claude Code, pip-installed tools)
export PATH="$HOME/.local/bin:$PATH"

# 共通環境変数（テンプレート: dotfiles/.env.example）
if [ -f "$HOME/.env" ]; then
  set -a
  . "$HOME/.env"
  set +a
fi

### ssh ###

if [ -n "$TERMUX_VERSION" ]; then
  # Termux: termux-services で管理される ssh-agent サービスのソケットを参照
  # 事前に: pkg install termux-services && sv-enable ssh-agent
  if [ -n "$XDG_RUNTIME_DIR" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  else
    export SSH_AUTH_SOCK="$PREFIX/var/run/ssh-agent.socket"
  fi

  ssh-add -l >/dev/null 2>&1
  _ssh_status=$?
  if [ $_ssh_status -eq 1 ]; then
    # エージェントは動いているが鍵未登録
    ssh-add
  fi
  unset _ssh_status
else
  # 通常環境: 固定ソケットパスで ssh-agent を管理する
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

  ssh-add -l >/dev/null 2>&1
  _ssh_status=$?

  if [ $_ssh_status -eq 2 ]; then
    # エージェント未起動またはソケットが無効 → 再起動
    mkdir -p -m 700 "$HOME/.ssh"
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



# source all shell function files
for __f in "$HOME/.local/share/dotfiles/functions/"*.sh; do
  [ -f "$__f" ] && . "$__f"
done
unset __f
