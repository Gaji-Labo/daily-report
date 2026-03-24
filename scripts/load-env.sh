#!/bin/bash
# .env ファイルから環境変数を読み込み、セッションに反映する
ENV_FILE="${CLAUDE_PLUGIN_ROOT}/.env"

if [ -f "$ENV_FILE" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  while IFS= read -r line; do
    # 空行とコメント行をスキップ
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo "export $line" >> "$CLAUDE_ENV_FILE"
  done < "$ENV_FILE"
fi

exit 0
