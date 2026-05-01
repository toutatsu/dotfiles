#!/usr/bin/env bash
# PR レビュー前の事前チェックスクリプト

set -euo pipefail

PR_ARG="${1:-}"

echo "=== PR 事前チェック ==="

# PR番号が指定された場合は gh でメタ情報を取得
if [[ -n "$PR_ARG" && "$PR_ARG" =~ ^[0-9]+$ ]]; then
  echo ""
  echo "--- PR #${PR_ARG} 基本情報 ---"
  gh pr view "$PR_ARG" --json title,state,author,baseRefName,headRefName,additions,deletions \
    --template '  タイトル : {{.title}}
  状態     : {{.state}}
  作成者   : {{.author.login}}
  マージ先 : {{.baseRefName}} ← {{.headRefName}}
  変更行数 : +{{.additions}} / -{{.deletions}}
'
  echo ""
  echo "--- チェックリスト ---"

  # CI ステータス
  STATUS=$(gh pr view "$PR_ARG" --json statusCheckRollup --jq '.statusCheckRollup[].conclusion // "pending"' 2>/dev/null | sort -u | tr '\n' ',')
  if echo "$STATUS" | grep -qi "failure"; then
    echo "  ❌ CI: 失敗あり ($STATUS)"
  elif echo "$STATUS" | grep -qi "pending\|in_progress"; then
    echo "  ⏳ CI: 実行中 ($STATUS)"
  else
    echo "  ✅ CI: 成功"
  fi

  # 変更ファイル数
  CHANGED=$(gh pr view "$PR_ARG" --json files --jq '.files | length')
  echo "  📁 変更ファイル数: ${CHANGED}"

  # レビュー状況
  REVIEWS=$(gh pr view "$PR_ARG" --json reviews --jq '[.reviews[] | .state] | unique | join(", ")' 2>/dev/null || echo "なし")
  echo "  👀 レビュー状況: ${REVIEWS:-なし}"

else
  # ブランチ指定 or 引数なし: ローカル diff の情報を表示
  echo ""
  echo "--- ローカル差分チェック ---"
  BASE="${PR_ARG:-main}"
  CHANGED=$(git diff --name-only "${BASE}...HEAD" 2>/dev/null | wc -l | tr -d ' ')
  ADDITIONS=$(git diff --stat "${BASE}...HEAD" 2>/dev/null | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
  DELETIONS=$(git diff --stat "${BASE}...HEAD" 2>/dev/null | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
  echo "  📁 変更ファイル数: ${CHANGED}"
  echo "  ➕ 追加行数: ${ADDITIONS}"
  echo "  ➖ 削除行数: ${DELETIONS}"
fi

echo ""
echo "=== チェック完了 ==="
