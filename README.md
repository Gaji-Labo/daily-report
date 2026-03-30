# daily-report — Claude Code / Cowork Plugin

GitHub / Jira / Slack のアクティビティを収集し、対話で所感・学びを引き出して esa に日報を投稿するプラグイン。Gaji-Labo Style（行動規範）との照合機能付き。

> **2 つのバリアントがあります**: Claude Code CLI 版（`skills/daily-report/`）と Cowork 版（`skills/daily-report-cowork/`）。詳細は [バリアント比較](#バリアント比較) を参照。

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
| `TARGET_REPOS` | いいえ | GitHub 収集対象リポジトリ (カンマ区切り) |
| `SLACK_CHANNELS` | いいえ | Slack 収集対象チャンネル ID (カンマ区切り) |

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

## バリアント比較

同じ日報を生成する 2 つのバリアントが存在する。実行環境に合わせて使い分ける。

| | Claude Code 版 | Cowork 版 |
|---|---|---|
| パス | `skills/daily-report/` | `skills/daily-report-cowork/` |
| 実行環境 | Claude Code CLI | Cowork（Claude Desktop） |
| GitHub | `gh` CLI | GitHub コネクタ |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| esa 投稿 | `post-to-esa.sh`（bash） | esa 公式 MCP サーバー |
| 対話 | `agents/report-interviewer.md` | SKILL.md 内に統合 |
| 環境変数 | 6 個 | 不要（コネクタ認証） |

`references/report-format.md` と `references/gaji-labo-style.md` は両バリアントで共通。変更時は両方を更新すること。

## プラグイン構成

### Claude Code 版

| ファイル | 役割 |
|----------|------|
| `skills/daily-report/SKILL.md` | メインワークフロー (5ステップ) |
| `agents/report-interviewer.md` | 所感・学びを引き出す対話エージェント |
| `skills/daily-report/references/report-format.md` | 日報フォーマット定義 |
| `skills/daily-report/references/gaji-labo-style.md` | Gaji-Labo Style 行動規範リファレンス |
| `skills/daily-report/scripts/post-to-esa.sh` | esa API 投稿/更新 |
| `hooks.json` + `scripts/check-report-reminder.sh` | 日報リマインダー |

### Cowork 版

| ファイル | 役割 |
|----------|------|
| `skills/daily-report-cowork/SKILL.md` | メインワークフロー (4ステップ、対話統合) |
| `skills/daily-report-cowork/references/report-format.md` | 日報フォーマット定義（Claude Code 版と同一） |
| `skills/daily-report-cowork/references/gaji-labo-style.md` | Gaji-Labo Style 行動規範リファレンス（同上） |

### Cowork 版のセットアップ

1. Claude Desktop で GitHub / Jira / Slack コネクタを接続
2. esa 公式 MCP サーバーを設定（参考: https://docs.esa.io/posts/561）
3. `skills/daily-report-cowork/` をスキルとしてアップロード

## License

MIT (c) 2026 yoshizawa
