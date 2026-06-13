---
name: commit
description: Stage and commit the current changes with a Conventional Commits message. Use when the user asks to commit, create a commit, or save changes to git.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git diff *) Bash(git status *) Bash(git log *)
---

Stage and commit the current changes following these steps:

1. Run `git status` to see untracked and modified files
2. Run `git diff` and `git diff --cached` to understand what changed
3. Run `git log --oneline -5` to match the repo's commit message style
4. Stage the relevant files with `git add <specific files>` — never use `git add -A` or `git add .`
5. Create a commit with a Conventional Commits message:

```
<type>(<scope>): <description>
```

**type の選択:**
- `feat`: 新機能
- `fix`: バグ修正
- `chore`: ビルド・設定変更（機能に影響しない）
- `docs`: ドキュメントのみの変更
- `refactor`: リファクタリング（機能変更なし）
- `style`: フォーマット変更（ロジック変更なし）
- `test`: テストの追加・修正

**制約:**
- `.env` などの機密ファイルをステージしない
- `--no-verify` を使わない
- コミットメッセージは英語で書く（description のみ）
- `Co-Authored-By: Claude <noreply@anthropic.com>` を末尾に追加する

$ARGUMENTS
