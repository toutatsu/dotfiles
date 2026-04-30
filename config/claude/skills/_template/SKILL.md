---
name: skill-name
description: 1文でスキルの目的を説明する。Claudeがいつ自動起動するかを決めるために使われる。最大1,536文字（description + when_to_use の合計）。
when_to_use: ユーザーが「〜して」「〜を確認して」などと言ったときに起動する、という補足説明（省略可）。
argument-hint: "[引数の説明]"
disable-model-invocation: false
allowed-tools: Read Grep Glob Bash(git *)
---

スキルの本文をここに書く。

## 手順

1. 最初のステップ
2. 次のステップ
3. 完了条件

## 出力形式

- 期待する出力の形式を記述する
- 日本語で回答する

## 追加ファイル（省略可）

- 詳細なリファレンスは [reference.md](reference.md) を参照
- サンプルは [examples/](examples/) を参照

$ARGUMENTS
