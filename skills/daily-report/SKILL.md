---
name: daily-report
description: |
  日報を作成して esa に投稿するスキル。
  GitHub / Jira / Slack からその日のアクティビティを自動収集し、
  ユーザーとの対話で所感・気づきを引き出してから日報を生成する。
  This skill should be used when the user says "日報を書きたい", "今日の日報",
  "daily report", "日報作成", "日報を投稿", "report to esa",
  or mentions writing an end-of-day summary.
---

# Daily report skill

GitHub、Jira、Slack からその日のアクティビティを収集し、対話で所感を引き出してから、esa に日報を投稿する。

## ワークフロー

以下の 5 ステップを順に実行する。途中でユーザーが中止を希望した場合はいつでも止める。

### Step 1: 日付の確認

ユーザーに対象日を確認する。指定がなければ今日の日付を使う。

### Step 2: アクティビティ収集

以下を **並列** で実行し、結果を集約する。

**GitHub** — `gh` CLI を使い、対象日の以下を取得:
```bash
gh search prs --author=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
gh search prs --author=@me --merged=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
gh search prs --reviewed-by=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
gh search issues --author=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
```

環境変数 `TARGET_REPOS` が設定されていればカンマ区切りで `--repo` フラグを付与する。

**Jira** — MCP ツール `mcp__atlassian` が利用可能なら:
- 当日アサインされて更新された Issue を検索
- 各 Issue のステータスとコメントを取得

**Slack** — MCP ツール `mcp__slack` が利用可能なら:
- 環境変数 `SLACK_CHANNELS` で指定されたチャンネルの当日の自分の発言を取得
- スレッド参加も含める

利用できないソースはスキップし、取得できたものだけで進める。

**収集結果の表示**: 何が取れたかをユーザーにフレンドリーに一覧表示する。

### Step 3: 対話で所感を引き出す

`daily-report:report-interviewer` エージェントに委譲する。

このエージェントは収集したアクティビティを踏まえて、ユーザーに 1〜2 個ずつ具体的な質問をし、
日報の「気づき・学び」「次やること」セクションに書くべき情報を引き出す。

対話は最大 5 ターンで、ユーザーが「done」や空入力で終了できる。

### Step 4: 日報 Markdown の生成

収集データと対話内容をもとに、`references/report-format.md` のフォーマットに従って日報を生成する。

生成後、ユーザーに Markdown 全文を表示し、以下の選択肢を提示:
- **そのまま投稿** する
- **修正点を指示** する (指示に従って再生成)
- **中止** する

### Step 5: esa に投稿

ユーザーが投稿を承認したら、`scripts/post-to-esa.sh` を実行する。

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/post-to-esa.sh \
  --title "YYYY-MM-DD 日報" \
  --body "$REPORT_MD" \
  --category "$REPORT_CATEGORY" \
  --wip "$WIP_FLAG"
```

必要な環境変数:
- `ESA_TEAM` — esa チーム名
- `ESA_TOKEN` — esa アクセストークン
- `REPORT_CATEGORY` — 投稿カテゴリ (デフォルト: `日報/$USER`)

投稿後、esa の URL をユーザーに表示して完了。

## 環境変数

| 変数 | 必須 | 説明 |
|------|------|------|
| `ESA_TEAM` | はい | esa チーム名 |
| `ESA_TOKEN` | はい | esa アクセストークン |
| `REPORT_CATEGORY` | いいえ | esa カテゴリ (デフォルト: `日報/$USER`) |
| `TARGET_REPOS` | いいえ | GitHub 対象リポジトリ (カンマ区切り) |
| `SLACK_CHANNELS` | いいえ | Slack チャンネル ID (カンマ区切り) |

## 前提

- `gh` CLI がインストール・認証済み
- Jira 連携は Atlassian MCP サーバーが接続済みであること
- Slack 連携は Slack MCP サーバーが接続済みであること
