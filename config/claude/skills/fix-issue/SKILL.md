---
name: fix-issue
description: GitHub issue を番号指定で修正する。コーディング規約に従って実装し、テストを書いてコミットまで行う。
argument-hint: "[issue-number]"
disable-model-invocation: true
allowed-tools: Bash(gh *) Bash(git *) Read Grep Glob
---

GitHub issue $ARGUMENTS を修正する:

1. `gh issue view $ARGUMENTS` で issue の内容を確認する
2. 関連ファイルを Grep・Glob で特定する
3. コーディング規約に従って実装する
4. テストを追加・修正する
5. `/commit` スキルでコミットする（メッセージに `fix #$ARGUMENTS` を含める）
