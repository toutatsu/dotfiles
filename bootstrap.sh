#!/bin/bash
# 新環境セットアップスクリプト
# 依存パッケージ確認・インストール、oh-my-zsh セットアップ、dotfiles インストールまでを実行する
set -u

repo_dir="$(cd "$(dirname "$0")" && pwd)"

# --- パッケージマネージャー検出 ---
if command -v apt-get &>/dev/null; then
  pkg_install() { sudo apt-get install -y "$@"; }
  pkg_check()   { dpkg -s "$1" &>/dev/null; }
elif command -v pkg &>/dev/null; then
  # Termux
  pkg_install() { pkg install -y "$@"; }
  pkg_check()   { pkg list-installed 2>/dev/null | grep -q "^$1/"; }
else
  echo "❌ サポートされていないパッケージマネージャーです (apt / pkg のみ対応)"
  exit 1
fi

echo ""
echo "🚀 dotfiles bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- 依存パッケージ確認・インストール ---
echo "📦 依存パッケージを確認中..."
packages=(git jq curl vim tmux zsh)
# dislocker は Termux 非対象
command -v pkg &>/dev/null || packages+=(dislocker)

missing=()
for p in "${packages[@]}"; do
  if ! pkg_check "$p" && ! command -v "$p" &>/dev/null; then
    missing+=("$p")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "  インストールが必要: ${missing[*]}"
  pkg_install "${missing[@]}"
  echo "  ✅ インストール完了"
else
  echo "  ✅ すべての依存パッケージが揃っています"
fi
echo ""

# --- oh-my-zsh ---
echo "🐚 oh-my-zsh を確認中..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  ✅ oh-my-zsh はインストール済みです"
else
  echo "  インストールします..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "  ✅ oh-my-zsh をインストールしました"
fi
echo ""

# --- マスター ~/.env ---
echo "🔑 シークレット設定ファイルを確認中..."

master_template="$repo_dir/config/claude/.env.example"
master_dest="$HOME/.env"

if [ ! -f "$master_dest" ]; then
  echo "  ⚠️  未作成: $master_dest"
  echo "       テンプレートからコピーして各値を設定してください:"
  echo "         cp $master_template $master_dest"
  echo "         \$EDITOR $master_dest"
  echo ""
  echo "  ❌ ~/.env が必須です。設定後に再実行してください。"
  exit 1
fi

echo "  ✅ $master_dest が存在します"
echo ""

# --- ツール固有 .env を ~/.env から生成 ---
# extract_vars <dest> <VAR1> [VAR2 ...] — 不足している変数のみ追記
extract_vars() {
  local dest="$1"; shift
  local vars=("$@")
  local dest_dir
  dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir"

  local added=false
  for var in "${vars[@]}"; do
    # ~/.env に設定されていない変数はスキップ
    local value
    value="$(grep -E "^${var}=" "$master_dest" | head -1 | cut -d= -f2-)"
    [ -z "$value" ] && continue

    # 既に dest に存在する変数はスキップ
    if [ -f "$dest" ] && grep -qE "^${var}=" "$dest"; then
      continue
    fi

    printf '%s=%s\n' "$var" "$value" >> "$dest"
    added=true
  done

  if [ "$added" = true ]; then
    echo "  ✅ 生成/更新:  $dest"
  else
    echo "  ⏭️  スキップ:   $dest (変数なし or 既存)"
  fi
}

echo "🔧 ツール固有 .env を生成中..."

# hermes: ~/.env から抽出（hermes は ~/.hermes/.env を直接読む）
extract_vars "$HOME/.hermes/.env" \
  ANTHROPIC_API_KEY OPENAI_API_KEY GOOGLE_API_KEY OPENROUTER_API_KEY \
  GROQ_API_KEY GITHUB_PERSONAL_ACCESS_TOKEN TOGETHER_API_KEY

# ntfy-claude: ntfy 専用変数を ~/.env から抽出
extract_vars "$HOME/.config/ntfy-claude.env" \
  NTFY_CLAUDE_URL NTFY_CLAUDE_AUTH

echo ""

# --- dotfiles インストール ---
echo "🏠 dotfiles をインストール中..."
"$repo_dir/install.sh"
