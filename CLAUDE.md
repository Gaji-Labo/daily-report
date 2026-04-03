# daily-report プラグイン

## 実行環境

このスキルは **Claude Code** と **Cowork（Claude Desktop）** の両方で動作する。
外部連携は実行環境に応じて利用可能な手段（`gh` CLI、MCP サーバー、コネクタ）を自動判定して使用する。

| サービス | Claude Code での手段 | Cowork での手段 |
|----------|---------------------|----------------|
| GitHub | `gh` CLI | GitHub MCP サーバー |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| Google Calendar | — | Google Calendar コネクタ |
| esa | `scripts/post-to-esa.sh` + 環境変数 | esa MCP サーバー |

各手段を利用するには、対応するセットアップが完了している必要がある（例: `gh auth login`、MCP サーバーの設定、コネクタの接続など）。全て揃っている必要はなく、利用可能なものだけで動作する。

## 環境変数（Claude Code 環境）

`~/.claude/settings.json` の `env` セクションで設定する。MCP サーバーやコネクタ経由の場合は不要。

| 変数 | 必須 | 説明 |
|------|------|------|
| `ESA_TEAM` | はい | esa チーム名 |
| `ESA_TOKEN` | はい | esa アクセストークン |
| `REPORT_CATEGORY` | いいえ | esa カテゴリ (デフォルト: `report/daily-report`) |
| `ESA_SCREEN_NAME` | いいえ | esa スクリーンネーム (タイトルに使用、デフォルト: `$USER`) |
| `TARGET_REPOS` | いいえ | GitHub 対象リポジトリ (カンマ区切り) |
| `SLACK_CHANNELS` | いいえ | Slack 対象チャンネル ID (カンマ区切り) |
