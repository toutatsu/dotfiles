# Shell bin / functions 管理 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ユーザー定義スクリプト・shell 関数を `config/shell/bin/` と `config/shell/functions/` で管理し、`install.sh` 実行時に `~/.local/bin` へリンクしてコマンドとして使えるようにする。

**Architecture:** `config/shell/bin/` に実行可能スクリプトを置きディレクトリごと `~/.local/bin` へシンボリックリンクする。`config/shell/functions/` には親シェルへの副作用（`cd` など）が必要な関数を `source` 用ファイルとして置き、`~/.local/share/dotfiles/functions` へリンクする。`.profile` はそのディレクトリを自動 `source` する。既存の `trash()` 関数定義は `.profile` から削除して `bin/trash` スクリプトに移植する。

**Tech Stack:** bash, POSIX sh, シンボリックリンク

---

## ファイルマップ

| 操作 | パス | 内容 |
|---|---|---|
| 作成 | `config/shell/bin/trash` | trash コマンド（既存の trash 関数をスクリプト化） |
| 作成 | `config/shell/bin/mkbak` | ファイルに .bak を付けてコピー |
| 作成 | `config/shell/functions/navigation.sh` | mkcd 関数（source 専用） |
| 変更 | `config/shell/.profile` | trash 関数定義を削除、functions/ を自動 source する処理を追加 |
| 変更 | `install.sh` | bin/ と functions/ のディレクトリリンクと mkdir を追加 |

---

### Task 1: bin/ と functions/ ディレクトリを作成し、サンプルスクリプトを追加する

**Files:**
- Create: `config/shell/bin/trash`
- Create: `config/shell/bin/mkbak`
- Create: `config/shell/functions/navigation.sh`

- [ ] **Step 1: ディレクトリを作成する**

```bash
mkdir -p config/shell/bin
mkdir -p config/shell/functions
```

- [ ] **Step 2: `config/shell/bin/trash` を作成する**

以下の内容で作成する：

```bash
#!/bin/bash
# ファイルを ~/.Trash に移動する（rm の代替）
set -euo pipefail
if [ $# -eq 0 ]; then
  echo "使い方: trash <file>..." >&2
  exit 1
fi
mkdir -p "$HOME/.Trash"
mv -i "$@" "$HOME/.Trash" && echo "moved to ~/.Trash: $*"
```

- [ ] **Step 3: `config/shell/bin/mkbak` を作成する**

以下の内容で作成する：

```bash
#!/bin/bash
# ファイルに .bak を付けてコピーする
set -euo pipefail
if [ $# -eq 0 ]; then
  echo "使い方: mkbak <file>..." >&2
  exit 1
fi
for f in "$@"; do
  if [ ! -e "$f" ]; then
    echo "ファイルが見つかりません: $f" >&2
    exit 1
  fi
  cp -i "$f" "${f}.bak" && echo "backup created: ${f}.bak"
done
```

- [ ] **Step 4: `config/shell/functions/navigation.sh` を作成する**

以下の内容で作成する（シバン行なし — source 専用）：

```bash
# mkcd: ディレクトリを作成して移動する
# スクリプト化できない（cd を親シェルに反映する必要があるため）
mkcd() {
  if [ $# -eq 0 ]; then
    echo "使い方: mkcd <dir>" >&2
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}
```

- [ ] **Step 5: スクリプトに実行権限を付与する**

```bash
chmod +x config/shell/bin/trash
chmod +x config/shell/bin/mkbak
```

- [ ] **Step 6: 動作を手動確認する**

```bash
bash config/shell/bin/trash --help 2>&1 || true
# Expected: "使い方: trash <file>..."

bash config/shell/bin/mkbak 2>&1 || true
# Expected: "使い方: mkbak <file>..."

# mkbak の実際の動作テスト
echo "test" > /tmp/testfile.txt
bash config/shell/bin/mkbak /tmp/testfile.txt
ls /tmp/testfile.txt.bak
# Expected: /tmp/testfile.txt.bak が存在する
rm /tmp/testfile.txt /tmp/testfile.txt.bak
```

- [ ] **Step 7: コミットする**

```bash
git add config/shell/bin/trash config/shell/bin/mkbak config/shell/functions/navigation.sh
git commit -m "feat: add shell bin/ and functions/ with trash, mkbak, mkcd"
```

---

### Task 2: `.profile` を更新する

**Files:**
- Modify: `config/shell/.profile`

- [ ] **Step 1: `.profile` から `trash(){}` 関数定義を削除する**

`config/shell/.profile` を開き、以下の行を削除する：

```bash
trash(){
  mv -i $@ ~/.Trash && echo "\`$@\` is moved to ~/.Trash"
}

# alias rm=trash
```

- [ ] **Step 2: functions/ を自動 source する処理を追加する**

`.profile` の末尾に以下を追記する：

```bash
# source all shell function files
for __f in "$HOME/.local/share/dotfiles/functions/"*.sh; do
  [ -f "$__f" ] && . "$__f"
done
unset __f
```

変数名を `__f` にしているのは、`f` などの短い変数名がユーザー定義と衝突するのを避けるため。

- [ ] **Step 3: `.profile` を source して動作確認する**

```bash
# 一時的に functions/ を本来のリンク先に置いて確認する
mkdir -p ~/.local/share/dotfiles/functions
cp config/shell/functions/navigation.sh ~/.local/share/dotfiles/functions/

bash -c 'source config/shell/.profile && type mkcd'
# Expected: mkcd is a function

# 後片付け（install.sh でリンクするため）
rm -rf ~/.local/share/dotfiles/functions
```

- [ ] **Step 4: コミットする**

```bash
git add config/shell/.profile
git commit -m "feat: auto-source functions/ in .profile, remove inline trash function"
```

---

### Task 3: `install.sh` を更新する

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: `mkdir -p` ブロックに 2 行追加する**

`install.sh` の以下のブロック：

```bash
if [ "$install" = true ]; then
  mkdir -p "$HOME/.config/opencode"
  mkdir -p "$HOME/.deepagents/agent"
  mkdir -p "$HOME/.codex"
  mkdir -p "$HOME/.hermes"
  mkdir -p "$HOME/.ssh/control"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
fi
```

を以下に変更する：

```bash
if [ "$install" = true ]; then
  mkdir -p "$HOME/.config/opencode"
  mkdir -p "$HOME/.deepagents/agent"
  mkdir -p "$HOME/.codex"
  mkdir -p "$HOME/.hermes"
  mkdir -p "$HOME/.ssh/control"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share/dotfiles"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
fi
```

- [ ] **Step 2: `dirs` 配列に 2 エントリを追加する**

`dirs` 配列：

```bash
dirs=(
  "config/deepagents/agents:$HOME/.deepagents/agent/agents"
  ...
  "config/codex/skills:$HOME/.codex/skills"
)
```

末尾の `"config/codex/skills:..."` の後に以下を追加する：

```bash
  "config/shell/bin:$HOME/.local/bin"
  "config/shell/functions:$HOME/.local/share/dotfiles/functions"
```

- [ ] **Step 3: `install.sh` を実行して動作確認する**

```bash
bash install.sh
```

Expected 出力（該当行抜粋）：
```
  🔗 リンク作成     /home/<user>/.local/bin
              → /path/to/dotfiles/config/shell/bin
  🔗 リンク作成     /home/<user>/.local/share/dotfiles/functions
              → /path/to/dotfiles/config/shell/functions
```

- [ ] **Step 4: リンクが正しく張られていることを確認する**

```bash
ls -la ~/.local/bin | head -5
# Expected: リポジトリの config/shell/bin へのシンボリックリンク

trash 2>&1 || true
# Expected: "使い方: trash <file>..."

mkbak 2>&1 || true
# Expected: "使い方: mkbak <file>..."
```

- [ ] **Step 5: CLAUDE.md のディレクトリ構成を更新する**

`CLAUDE.md` の `config/shell/` セクションに以下を追記する（`.profile` の行の下）：

```
  bin/    → ~/.local/bin (ディレクトリごとシンボリックリンク)
  functions/ → ~/.local/share/dotfiles/functions (source 専用)
```

- [ ] **Step 6: コミットする**

```bash
git add install.sh CLAUDE.md
git commit -m "feat: link shell/bin to ~/.local/bin and shell/functions via install.sh"
```
