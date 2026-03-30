---
name: daily-report
description: |
  日報を作成して esa に投稿するスキル。
  GitHub / Jira / Slack からその日のアクティビティを自動収集し、
  ユーザーとの対話で所感・気づきを引き出してから日報を生成する。
  このスキルは「日報を書きたい」「今日の日報」「daily report」「日報作成」
  「日報を投稿」「report to esa」などの発言や、
  一日の振り返りを書きたいという意図が見られたときに使用する。
---

# 日報作成スキル

GitHub、Jira、Slack からその日のアクティビティを収集し、対話で所感を引き出してから、esa に日報を投稿する。

## ワークフロー

以下の 5 ステップを順に実行する。途中でユーザーが中止を希望した場合はいつでも止める。

### Step 1: 日付の確認

ユーザーに対象日を確認する。指定がなければ今日の日付を使う。

### Step 2: アクティビティ収集

以下を **並列** で実行し、結果を集約する。各ソースは利用可能な手段（`gh` CLI、MCP サーバー、コネクタ）のうち使えるものを自動判定して取得する。利用できないソースはスキップし、取得できたものだけで進める。

**GitHub** — 対象日の以下を取得:
- 自分が作成した PR
- 自分がマージした PR
- 自分がレビューした PR
- 自分が作成した Issue
- 自分のコミット
- 自分が書いた PR コメント
- 自分の PR に対する他者からのレビュー（承認・変更要求・行コメント）

取得手段の優先順位:
1. **`gh` CLI** が利用可能な場合（Claude Code 環境）:
   ```bash
   gh search prs --author=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
   gh search prs --author=@me --merged-at=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
   gh search prs --reviewed-by=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
   gh search issues --author=@me --created=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,title,url,state,number --limit 50
   gh search commits --author=@me --committer-date=YYYY-MM-DDT00:00:00..YYYY-MM-DDT23:59:59 --json repository,sha,commit --limit 50
   ```
   コメント・レビューは `gh api` で取得:
   ```bash
   gh api '/search/issues?q=commenter:@me+type:pr+updated:YYYY-MM-DD..YYYY-MM-DD&per_page=50' --jq '.items[] | {repo: .repository_url, title: .title, number: .number, url: .html_url}'
   gh api '/repos/{owner}/{repo}/pulls/{number}/reviews' --jq '[.[] | select(.user.login != "{username}" and (.submitted_at | startswith("YYYY-MM-DD")))] | .[] | {user: .user.login, state: .state, body: .body}'
   gh api '/repos/{owner}/{repo}/pulls/{number}/comments' --jq '[.[] | select(.user.login != "{username}" and (.created_at | startswith("YYYY-MM-DD")))] | .[] | {user: .user.login, body: .body, path: .path}'
   ```
   環境変数 `TARGET_REPOS` が設定されていればカンマ区切りで `--repo` フラグを付与する。

2. **GitHub MCP サーバー** が利用可能な場合（Cowork 環境等）: MCP ツール経由で同等の情報を取得する。

**Jira** — 対象日の以下を取得:
- 当日アサインされて更新された Issue
- 各 Issue のステータスとコメント

取得手段: Atlassian MCP サーバー (`mcp__atlassian`)、Jira コネクタ、いずれか利用可能なものを使用。

**Slack** — 対象日の以下を取得:
- 自分の発言（チャンネル投稿・スレッド参加）

取得手段: Slack MCP サーバー (`mcp__slack`)、Slack コネクタ、いずれか利用可能なものを使用。環境変数 `SLACK_CHANNELS` が設定されていれば対象チャンネルを絞り込む。

**収集結果の表示**: 何が取れたかをユーザーにフレンドリーに一覧表示する。受け取ったレビューがある場合は、誰からどのような指摘・承認があったかも含める。

### Step 3: 対話で所感を引き出す

`daily-report:report-interviewer` エージェントに委譲する。

エージェントに渡すデータ:
- 収集したアクティビティログ
- `references/gaji-labo-style.md` の Gaji-Labo Style 一覧

このエージェントは収集したアクティビティを踏まえて、ユーザーに 1〜2 個ずつ具体的な質問をし、
日報の「気づき・学び」「次やること」「今日の Gaji-Labo Style」セクションに書くべき情報を引き出す。
対話の中でミーティングでの発言や Slack での気遣いなどコミュニケーション面も引き出し、
最後にユーザーの良い行動を Gaji-Labo Style に照らして提案する。

ユーザーが「done」や空入力で終了できる。

### Step 4: 日報 Markdown の生成

収集データと対話内容をもとに、`references/report-format.md` のフォーマットに従って日報を生成する。

生成後、ユーザーに Markdown 全文を表示し、以下の選択肢を提示:
- **そのまま投稿** する
- **修正点を指示** する (指示に従って再生成)
- **中止** する

### Step 5: esa に投稿

ユーザーが投稿を承認したら、利用可能な手段で esa に投稿する。

- タイトル形式: `Daily 振り返り YYYY.MM.DD：ユーザー名 #reflection`
- 同日の記事が既に存在する場合は上書き更新する
- 投稿後、esa の URL をユーザーに表示して完了

投稿手段の優先順位:
1. **esa MCP サーバー** が利用可能な場合: MCP ツール経由で投稿する。
2. **`scripts/post-to-esa.sh`** が実行可能な場合（Claude Code 環境）:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/post-to-esa.sh \
     --title "Daily 振り返り YYYY.MM.DD：${ESA_SCREEN_NAME:-$USER} #reflection" \
     --body "$REPORT_MD" \
     --category "${REPORT_CATEGORY:-report/daily-report}" \
     --wip "$WIP_FLAG"
   ```

## 環境変数（Claude Code 環境で `scripts/post-to-esa.sh` を使う場合）

`~/.claude/settings.json` の `env` セクションで設定する。
MCP サーバーやコネクタ経由で連携する場合は不要。

| 変数 | 必須 | 説明 |
|------|------|------|
| `ESA_TEAM` | はい | esa チーム名 |
| `ESA_TOKEN` | はい | esa アクセストークン |
| `REPORT_CATEGORY` | いいえ | esa カテゴリ (デフォルト: `report/daily-report`) |
| `ESA_SCREEN_NAME` | いいえ | esa スクリーンネーム (タイトルに使用、デフォルト: `$USER`) |
| `TARGET_REPOS` | いいえ | GitHub 対象リポジトリ (カンマ区切り、`gh` CLI 使用時) |
| `SLACK_CHANNELS` | いいえ | Slack チャンネル ID (カンマ区切り、Slack MCP 使用時) |

## 前提

以下のうち、利用する連携手段に応じたセットアップが必要。全て揃っている必要はなく、利用可能なものだけで動作する。

| サービス | 手段 A | 手段 B |
|----------|--------|--------|
| GitHub | `gh` CLI（`gh auth login` で認証） | GitHub MCP サーバー |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| esa | `scripts/post-to-esa.sh` + 環境変数 | esa MCP サーバー（公式: https://docs.esa.io/posts/561） |
