---
name: pr-review
description: PR の diff を取得してコードレビューを行う。セキュリティ・品質・可読性の観点で指摘する。
argument-hint: "[PR番号 または ブランチ名]"
context: fork
agent: code-reviewer
allowed-tools: Bash(gh *) Bash(git *) Read Grep Glob
---

# PR レビュー

## テンプレート

参照: `${CLAUDE_SKILL_DIR}/template.md`

## 出力サンプル

参照: `${CLAUDE_SKILL_DIR}/examples/sample.md`

## 事前チェック

!`bash ${CLAUDE_SKILL_DIR}/scripts/validate.sh $ARGUMENTS`

## Diff

!`gh pr diff $ARGUMENTS 2>/dev/null || git diff main...HEAD`

## レビュー指示

上記 diff を `template.md` の形式に従ってレビューせよ。

- セキュリティリスク（OWASP Top 10）を最優先で指摘する
- 品質・可読性の問題を次に指摘する
- 問題がない場合は「指摘なし」と明記する
- 各指摘には該当ファイルと行番号を添える
- `examples/sample.md` の出力形式を参考にすること
