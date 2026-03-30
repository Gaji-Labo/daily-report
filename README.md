# daily-report — Claude Code / Cowork Plugin

GitHub / Jira / Slack のアクティビティを収集し、対話で所感・学びを引き出して esa に日報を投稿するプラグイン。Gaji-Labo Style（行動規範）との照合機能付き。

Claude Code と Cowork の両方で動作する。外部連携は実行環境に応じて利用可能な手段（`gh` CLI、MCP サーバー、コネクタ）を自動判定して使用する。

## インストール

### Claude Code（ローカル）

```bash
claude --plugin-dir /path/to/daily-report-plugin
```

### marketplace 経由

```bash
/plugin marketplace add https://github.com/Gaji-Labo/daily-report
/plugin install daily-report@gaji-labo-plugins
```

### Cowork

`skills/daily-report/` をスキルとしてアップロードする。

## セットアップ

外部連携は利用可能な手段のうちいずれかをセットアップすればよい。全て揃っている必要はない。

### 外部連携の手段

| サービス | 手段 A | 手段 B |
|----------|--------|--------|
| GitHub | `gh` CLI（`gh auth login` で認証） | GitHub MCP サーバー |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| esa | `scripts/post-to-esa.sh` + 環境変数 | esa MCP サーバー（公式: https://docs.esa.io/posts/561） |

接続されていないソースは自動スキップされる。

### 環境変数（`scripts/post-to-esa.sh` を使う場合）

MCP サーバーやコネクタ経由で連携する場合は不要。

`~/.claude/settings.json` の `env` セクションに設定する。

```json
{
  "env": {
    "ESA_TEAM": "gaji",
    "ESA_TOKEN": "your-esa-token",
    "REPORT_CATEGORY": "report/daily-report",
    "ESA_SCREEN_NAME": "your-name",
    "TARGET_REPOS": "org/repo1,org/repo2",
    "SLACK_CHANNELS": "C01XXXX,C02YYYY"
  }
}
```

| 変数 | 必須 | 説明 |
|------|------|------|
| `ESA_TEAM` | はい | esa チーム名 (`https://<team>.esa.io`) |
| `ESA_TOKEN` | はい | esa アクセストークン |
| `REPORT_CATEGORY` | いいえ | esa 投稿カテゴリ (デフォルト: `report/daily-report`) |
| `ESA_SCREEN_NAME` | いいえ | タイトルに使う表示名 (デフォルト: `$USER`) |
| `TARGET_REPOS` | いいえ | GitHub 収集対象リポジトリ (カンマ区切り、`gh` CLI 使用時) |
| `SLACK_CHANNELS` | いいえ | Slack 収集対象チャンネル ID (カンマ区切り) |

## 使い方

```
/daily-report
```

または「日報を書きたい」「今日の日報」と発言する。

### フロー

1. 日付確認
2. GitHub / Jira / Slack からアクティビティ収集（PR、コミット、コメント、受けたレビューなど）
3. AI との対話で所感・学びを引き出す
   - アクティビティの補完（ログに出ない作業やコミュニケーション面も拾い上げ）
   - 知見の深掘り（十分な学びが出るまでループ）
   - 次やることの確認
   - Gaji-Labo Style の提案と採否選択
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

## 今日の Gaji-Labo Style
- Style #N「スタイル名」— 該当する行動と理由
```

### リマインダー

平日 17〜20 時にセッション終了すると、未投稿なら自動リマインド。

## プラグイン構成

| ファイル | 役割 |
|----------|------|
| `skills/daily-report/SKILL.md` | メインワークフロー (5ステップ) |
| `agents/report-interviewer.md` | 所感・学びを引き出す対話エージェント |
| `skills/daily-report/references/report-format.md` | 日報フォーマット定義 |
| `skills/daily-report/references/gaji-labo-style.md` | Gaji-Labo Style 行動規範リファレンス |
| `skills/daily-report/scripts/post-to-esa.sh` | esa API 投稿/更新 (Claude Code 環境用) |
| `hooks.json` + `scripts/check-report-reminder.sh` | 日報リマインダー (Claude Code 環境用) |

## License

MIT (c) 2026 yoshizawa
