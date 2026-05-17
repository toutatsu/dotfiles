# Shell bin / functions 管理設計

## 概要

ユーザー定義のスクリプトと shell 関数を dotfiles で管理し、`make install` 時に `~/.local/bin` へリンクして即座に使えるようにする。

## ディレクトリ構成

```
config/shell/
  .profile                        ← functions/ を自動 source する処理を追記、trash 関数定義を削除
  bin/                            ← 実行可能スクリプト → ~/.local/bin にディレクトリごとリンク
    trash                         ← 既存の trash 関数をスクリプト化
    mkbak                         ← 例: ファイルに .bak を付けてコピー
  functions/                      ← source 専用（親シェルへの副作用が必要なもの）
    navigation.sh                 ← 例: mkcd（mkdir して cd）
```

## リンク方針

| リポジトリパス | リンク先 | 方法 |
|---|---|---|
| `config/shell/bin` | `~/.local/bin` | ディレクトリごとシンボリックリンク（`dirs` に追加） |
| `config/shell/functions` | `~/.local/share/dotfiles/functions` | ディレクトリごとシンボリックリンク（`dirs` に追加） |

`~/.local/bin` は既に `.profile` の `PATH` に含まれているため、リンク後すぐコマンドとして使える。

## .profile の変更

```bash
# source all function files
for f in "$HOME/.local/share/dotfiles/functions/"*.sh; do
  [ -f "$f" ] && source "$f"
done
```

- `trash(){}` の関数定義を削除（`bin/trash` で代替）

## サンプルファイル

### `bin/trash`

```bash
#!/bin/bash
# ファイルを ~/.Trash に移動する（rm の代替）
set -euo pipefail
mkdir -p "$HOME/.Trash"
mv -i "$@" "$HOME/.Trash" && echo "moved to ~/.Trash: $*"
```

### `bin/mkbak`

```bash
#!/bin/bash
# ファイルに .bak を付けてコピーする
set -euo pipefail
for f in "$@"; do
  cp -i "$f" "${f}.bak" && echo "backup created: ${f}.bak"
done
```

### `functions/navigation.sh`

```bash
# mkcd: ディレクトリを作成して移動する（親シェルへの cd が必要なため source 専用）
mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

## bin/ スクリプトの規約

- シバン行 `#!/bin/bash` を先頭に記載
- `set -euo pipefail` でエラー時即終了
- 実行権限 `chmod +x` を付与（リポジトリ内で設定）
- `functions/` に置くのは「親シェルへの副作用（cd など）が必要なもの」のみ

## install.sh の変更

`dirs` 配列に以下を追加：

```bash
"config/shell/bin:$HOME/.local/bin"
"config/shell/functions:$HOME/.local/share/dotfiles/functions"
```

`mkdir -p` で事前作成するディレクトリに追加：

```bash
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/dotfiles"
```
