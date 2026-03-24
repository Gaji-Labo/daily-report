#!/usr/bin/env bash
HOUR=$(date +%H)
DOW=$(date +%u)

# 平日 17〜20 時のみ
if [[ "$DOW" -gt 5 ]] || [[ "$HOUR" -lt 17 ]] || [[ "$HOUR" -gt 20 ]]; then
  exit 0
fi

if [[ -z "${ESA_TEAM:-}" ]] || [[ -z "${ESA_TOKEN:-}" ]]; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d)
TITLE="${TODAY} 日報"
CATEGORY="${REPORT_CATEGORY:-日報/${USER:-me}}"
SEARCH_Q=$(echo "$TITLE" | sed 's/ /%20/g')

RESULT=$(curl -s "https://api.esa.io/v1/teams/${ESA_TEAM}/posts?q=title:${SEARCH_Q}+in:${CATEGORY}" \
  -H "Authorization: Bearer ${ESA_TOKEN}" 2>/dev/null || echo '{"posts":[]}')

COUNT=$(echo "$RESULT" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('posts',[])))" 2>/dev/null || echo "0")

if [[ "$COUNT" -eq 0 ]]; then
  cat <<EOF
{
  "systemMessage": "💡 今日の日報がまだ投稿されていないようです。 /daily-report:daily-report で日報を作成できます。"
}
EOF
fi
