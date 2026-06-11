# 改善タスク仕様書

2026-06-11 のリポジトリ全体レビューで挙がった残タスク。機械的な修正（バグ修正・命名・ドキュメント同期）は対応済みで、ここには機能追加系のみ残している。各タスクは独立しており、1 タスク = 1 ブランチ / 1 コミット系列で進めてよい。

前提知識は `CLAUDE.md` を参照（install.sh の file_links / dir_links / spread_dirs 方式、バックアップ拡張子 `*.pre-dotfiles`、readlink 検証によるリポジトリ外リンクの保護）。

## 優先度: 低（設計判断が必要）

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
