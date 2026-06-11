# 改善タスク仕様書

2026-06-11 のリポジトリ全体レビューで挙がった残タスク。機械的な修正（バグ修正・命名・ドキュメント同期）は対応済みで、ここには機能追加系のみ残している。各タスクは独立しており、1 タスク = 1 ブランチ / 1 コミット系列で進めてよい。

前提知識は `CLAUDE.md` を参照（install.sh の file_links / dir_links / spread_dirs 方式、バックアップ拡張子 `*.pre-dotfiles`、readlink 検証によるリポジトリ外リンクの保護）。

## 優先度: 高

### 2. DeepAgents AGENTS.md リンクの修正

**背景:** `install.sh` の file_links に `config/deepagents/AGENTS.md:$HOME/.deepagents/agent/AGENTS.md` があるが、リンク作成時にエラーが発生するため現在コメントアウト中（install.sh 内の `# エラーが発生するため無効化` 行）。

**作業内容:**
- エラーの原因を調査する。候補: `~/.deepagents/agent` を DeepAgents CLI 自身が管理していて競合する / 既存の実体ファイルとの衝突 / リンク先パスがそもそも誤り
- DeepAgents CLI が実際に AGENTS.md を読むパスを確認し、正しいリンク先に修正してコメントアウトを解除する
- 修正不能（CLI が実体ファイルを要求する等）なら、コメントを「なぜ無効か」が分かる説明に書き換え、`CLAUDE.md` に制約として記載する

**受け入れ条件:** 仮 HOME（`HOME=$(mktemp -d)`）でのインストールが 失敗: 0 のまま、AGENTS.md がリンクされる（または無効である理由がドキュメント化されている）。

### 3. CI（GitHub Actions）

**背景:** 今回の修正検証は手動スモークテスト（仮 HOME で install → uninstall → 残存リンク 0 を確認）だった。これを自動化して再発を防ぐ。

**作業内容:** `.github/workflows/ci.yml` を作成し、push / PR で以下を実行:
- `shellcheck` — `install.sh` と `config/shell/bin/` 配下の全スクリプト（shebang が bash のもの）
- スモークテスト:
  ```bash
  export HOME=$(mktemp -d)
  ./install.sh          # 出力に「失敗:」の数値が 0 であること（exit code は失敗数を反映しないため出力を検証）
  ./install.sh          # 冪等性: 2 回目は全てスキップ、失敗 0
  ./install.sh --uninstall
  test "$(find "$HOME" -type l | wc -l)" -eq 0
  ```
- `jq` を使うスクリプト（claude-statusline, ntfy-claude-hook）はサンプル JSON を流して exit 0 を確認

**受け入れ条件:** ワークフローが green。shellcheck の既存指摘はこのタスク内で修正する（量が多ければ別コミットに分割）。

## 優先度: 中

### 4. install.sh `--dry-run` オプション

**作業内容:** 実際にはリンク作成・バックアップ・削除を行わず、何が起きるかだけを通常と同じフォーマットで表示する。`process_file` / `process_dir` 内の副作用（mv / ln / rm / mkdir / chmod）を `$dry_run` フラグでガードする実装が素直。

**受け入れ条件:** `--dry-run` 実行前後で `find $HOME -newer <marker>` に差分がない。表示内容は実実行時と一致する。

### 5. install.sh `status` サブコマンド

**作業内容:** 管理対象（file_links / dir_links / spread_dirs 展開後）の各エントリについて状態を一覧表示する:
- ✅ リンク済み（このリポジトリを指す）
- ❌ 未リンク
- ⚠️ 別の場所を指すリンク / リンクでない実体ファイルが存在
- 💀 リンク切れ（リンクはあるが指す先が存在しない）

末尾にカウントのサマリを表示。引数パースを `--uninstall` と統合する（`install` / `uninstall` / `status` のサブコマンド形式に整理してもよいが、既存の `--uninstall` は後方互換のため残す）。

### 6. install.sh `--force` オプション

**作業内容:** 現在「別の場所を指すリンクが存在します」でスキップされるケースを、`--force` 指定時はバックアップ（`*.pre-dotfiles`）してから上書きする。リンクのバックアップは `mv` でリンク自体を退避する（実体のコピーはしない）。

**受け入れ条件:** 仮 HOME で外部リンクを仕込み、`--force` なしでスキップ・ありで上書き＆バックアップされることを確認。

## 優先度: 低（設計判断が必要）

### 7. bootstrap スクリプト

新環境セットアップの全自動化: 依存パッケージ確認（git, jq, curl, vim, tmux, zsh, dislocker）、oh-my-zsh インストール、`.env` テンプレート群の配置案内、`install.sh` 実行、までを 1 コマンドで。apt / pkg (Termux) の分岐が必要。

### 8. MCP サーバー登録の自動化

`CLAUDE.md` 記載の `claude mcp add` 手順をスクリプト化（例: `config/shell/bin/claude-mcp-setup`）。トークンは `~/.env` から読む。冪等性（登録済みならスキップ）を持たせる。

### 9. opencode tools の整理統合

`config/opencode/tools/` 配下のカスタムツールを棚卸しし、重複・未使用を削除、命名を統一する。opencode の skills と機能が被るものは skills 側へ寄せる。

### 10. シークレット管理の体系化

現在 `.env` ファイルが 5 箇所以上に分散（`~/.env`, `~/.deepagents/.env`, `~/.codex/.env`, `~/.config/opencode/.env`, `~/.hermes/.env`, `~/.config/ntfy-claude.env`）。`~/.env` を単一のソースとし、各ツール固有 env はそこから参照・生成する方式を検討する。`.profile` の `set -a` 読み込み（対応済み）が基盤になる。

---

## 進め方の注意

- 無関係な変更は別コミットに分ける（コミットメッセージは既存の Conventional Commits 形式・日本語に合わせる）
- install.sh には `set -e` を入れない（`(( x++ )) || true` のカウンタ方式と衝突する）
- 動作検証は必ず仮 HOME（`HOME=$(mktemp -d)`）で行い、実環境の `$HOME` を汚さない
- 完了したタスクはこのファイルから削除する
