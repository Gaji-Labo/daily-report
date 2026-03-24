# daily-report — Claude Code Plugin

GitHub / Jira / Slack のアクティビティを収集し、対話で所感を引き出して esa に日報を投稿する Claude Code プラグイン。

## インストール

```bash
# ローカルでテスト
claude --plugin-dir ./daily-report-plugin

# marketplace 経由 (公開後)
claude plugin install daily-report
```

## セットアップ

### 1. 環境変数

```bash
# 必須
export ESA_TEAM="your-team"
export ESA_TOKEN="your-esa-token"

# 任意
export REPORT_CATEGORY="日報/your-name"
export TARGET_REPOS="org/repo1,org/repo2"
export SLACK_CHANNELS="C01XXXX,C02YYYY"
```

### 2. 外部ツール

| ツール | 用途 | セットアップ |
|--------|------|-------------|
| `gh` CLI | GitHub アクティビティ収集 | `gh auth login` で認証 |
| Atlassian MCP | Jira チケット収集 | Claude Code の MCP 設定で接続 |
| Slack MCP | Slack 発言収集 | Claude Code の MCP 設定で接続 |

Jira / Slack は任意。接続されていないソースは自動スキップ。

### 3. esa トークン

`https://<team>.esa.io/user/applications` → read + write スコープで発行

## 使い方

```
日報を書きたい
/daily-report:daily-report
```

### フロー

1. 📅 日付確認
2. 🔍 GitHub / Jira / Slack からアクティビティ収集
3. 💬 AI が所感・気づきを対話で引き出す
4. 📝 日報 Markdown を生成 → プレビュー
5. ✅ esa に投稿 (同日記事があれば上書き更新)

### リマインダー

平日 17〜20 時にセッション終了すると、未投稿なら自動リマインド。

## プラグイン構成

| ファイル | 役割 |
|----------|------|
| `skills/daily-report/SKILL.md` | メインワークフロー (5ステップ) |
| `agents/report-interviewer.md` | 所感を引き出す対話エージェント |
| `skills/daily-report/references/report-format.md` | 日報フォーマット定義 |
| `skills/daily-report/scripts/post-to-esa.sh` | esa API 投稿/更新 |
| `hooks.json` + `scripts/check-report-reminder.sh` | 日報リマインダー |

## License

MIT
