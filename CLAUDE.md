# daily-report プラグイン

## 実行環境

このスキルは **Claude Code** と **Cowork（Claude Desktop）** の両方で動作する。
外部連携は実行環境に応じて利用可能な手段（`gh` CLI、MCP サーバー、コネクタ）を自動判定して使用する。

| サービス | Claude Code での手段 | Cowork での手段 |
|----------|---------------------|----------------|
| GitHub | `gh` CLI | GitHub MCP サーバー |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| esa | `scripts/post-to-esa.sh` + 環境変数 | esa MCP サーバー |
