#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  esa に日報を投稿するスクリプト
#  daily-report スキルの Step 5 から呼び出される
#
#  使い方:
#    post-to-esa.sh --title "2026-03-24 日報" --body "## やったこと ..." \
#                   [--category "日報/username"] [--wip true]
# ============================================================

ESA_TEAM="${ESA_TEAM:?ESA_TEAM が未設定です。esa チーム名を環境変数にセットしてください。}"
ESA_TOKEN="${ESA_TOKEN:?ESA_TOKEN が未設定です。esa アクセストークンを環境変数にセットしてください。}"

TITLE=""
BODY=""
CATEGORY="${REPORT_CATEGORY:-日報/${USER:-me}}"
WIP="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)    TITLE="$2";    shift 2 ;;
    --body)     BODY="$2";     shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --wip)      WIP="$2";      shift 2 ;;
    -h|--help)
      echo "使い方: $0 --title TITLE --body BODY [--category CAT] [--wip true|false]"
      exit 0 ;;
    *) echo "不明なオプション: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$TITLE" || -z "$BODY" ]]; then
  echo "Error: --title と --body は必須です" >&2
  exit 1
fi

if [[ "$WIP" == "true" ]]; then WIP_JSON="true"; else WIP_JSON="false"; fi

# --- 同日の既存記事を検索 ---
ESA_API="https://api.esa.io/v1/teams/${ESA_TEAM}"
SEARCH_Q=$(echo "$TITLE" | sed 's/ /%20/g')

EXISTING=$(curl -s "${ESA_API}/posts?q=title:${SEARCH_Q}+in:${CATEGORY}" \
  -H "Authorization: Bearer ${ESA_TOKEN}" \
  -H "Content-Type: application/json")

EXISTING_ID=$(echo "$EXISTING" | python3 -c "
import sys, json
data = json.load(sys.stdin)
posts = data.get('posts', [])
for p in posts:
    if p.get('name') == '$TITLE':
        print(p['number'])
        break
" 2>/dev/null || true)

FULL_BODY="# ${TITLE}

${BODY}"

PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'post': {
        'name': sys.argv[1],
        'body_md': sys.argv[2],
        'category': sys.argv[3],
        'wip': sys.argv[4] == 'true',
        'message': '日報自動作成 (daily-report plugin)',
    }
}))
" "$TITLE" "$FULL_BODY" "$CATEGORY" "$WIP")

if [[ -n "$EXISTING_ID" ]]; then
  echo "既存記事 (#${EXISTING_ID}) を更新します..." >&2
  RESPONSE=$(curl -s -X PATCH "${ESA_API}/posts/${EXISTING_ID}" \
    -H "Authorization: Bearer ${ESA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")
else
  echo "新規記事を作成します..." >&2
  RESPONSE=$(curl -s -X POST "${ESA_API}/posts" \
    -H "Authorization: Bearer ${ESA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")
fi

URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('url',''))" 2>/dev/null || true)
ERROR=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error',''))" 2>/dev/null || true)

if [[ -n "$URL" ]]; then
  if [[ -n "$EXISTING_ID" ]]; then
    echo "✅ 更新完了: ${URL}"
  else
    echo "✅ 投稿完了: ${URL}"
  fi
else
  echo "❌ 投稿に失敗しました" >&2
  if [[ -n "$ERROR" ]]; then echo "   エラー: ${ERROR}" >&2
  else echo "   レスポンス: ${RESPONSE}" >&2; fi
  exit 1
fi
