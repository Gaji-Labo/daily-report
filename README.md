# daily-report — Claude Code Plugin

GitHub / Jira / Slack のアクティビティを収集し、対話で所感を引き出して esa に日報を投稿する Claude Code プラグイン。

## インストール

### ローカルから

```bash
claude --plugin-dir /path/to/daily-report-plugin
```

### marketplace 経由

```bash
/plugin marketplace add https://github.com/Gaji-Labo/daily-report
/plugin install daily-report@gaji-labo-plugins
```

## セットアップ

### 1. 環境変数

`.env.sample` を `.env` にコピーして値を設定する。

```bash
cp .env.sample .env
```

```bash
# 必須
ESA_TEAM="gaji"                          # esa チーム名 (https://<team>.esa.io)
ESA_TOKEN="your-esa-token"               # esa アクセストークン

# 任意
REPORT_CATEGORY="report/daily-report"    # esa 投稿カテゴリ
ESA_SCREEN_NAME="your-name"              # タイトルに使う表示名 (デフォルト: $USER)
TARGET_REPOS="org/repo1,org/repo2"       # GitHub 収集対象リポジトリ
SLACK_CHANNELS="C01XXXX,C02YYYY"         # Slack 収集対象チャンネル ID
```

### 2. esa トークンの発行

`https://<team>.esa.io/user/applications` から read + write スコープで発行する。

### 3. 外部連携 (任意)

接続されていないソースは自動スキップされるため、すべて任意。

| ツール | 用途 | セットアップ |
|--------|------|-------------|
| `gh` CLI | GitHub アクティビティ収集 | `gh auth login` で認証 |
| Atlassian MCP | Jira チケット収集 | `/mcp add --transport sse atlassian https://mcp.atlassian.com/v1/mcp` |
| Slack MCP | Slack 発言収集 | Claude Code の MCP 設定で接続 |

## 使い方

```
/daily-report
```

または「日報を書きたい」「今日の日報」と発言する。

### フロー

1. 日付確認
2. GitHub / Jira / Slack からアクティビティ収集
3. AI が所感・気づきを対話で引き出す
4. 日報 Markdown を生成・プレビュー
5. esa に投稿 (同日記事があれば上書き更新)

### 日報フォーマット

タイトル: `Daily 振り返り YYYY.MM.DD：表示名 #reflection`

```markdown
## 今日やったこと
- 作業内容

## 今日学んだこと
- 気づき・学び

## 次にするべきこと
- 翌日以降のタスク
```

### リマインダー

平日 17〜20 時にセッション終了すると、未投稿なら自動リマインド。

## プラグイン構成

| ファイル | 役割 |
|----------|------|
| `skills/daily-report/SKILL.md` | メインワークフロー (5ステップ) |
| `agents/report-interviewer.md` | 所感を引き出す対話エージェント |
| `skills/daily-report/references/report-format.md` | 日報フォーマット定義 |
| `skills/daily-report/scripts/post-to-esa.sh` | esa API 投稿/更新 |
| `scripts/load-env.sh` | .env 読み込み (SessionStart hook) |
| `hooks.json` + `scripts/check-report-reminder.sh` | 日報リマインダー |

## License

MIT (c) 2026 yoshizawa
