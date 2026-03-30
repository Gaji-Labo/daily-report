# daily-report プラグイン

## 2 つのスキルバリアント

このリポジトリには同じ日報作成スキルの **2 つのバリアント** が並行して存在する。どちらも同じ日報を生成するが、実行環境と外部連携の方式が異なる。

| | `daily-report`（Claude Code 版） | `daily-report-cowork`（Cowork 版） |
|---|---|---|
| パス | `skills/daily-report/` | `skills/daily-report-cowork/` |
| 実行環境 | Claude Code CLI | Cowork（Claude Desktop） |
| GitHub | `gh` CLI | GitHub コネクタ |
| Jira | Atlassian MCP サーバー | Jira コネクタ |
| Slack | Slack MCP サーバー | Slack コネクタ |
| esa 投稿 | `post-to-esa.sh`（bash スクリプト） | esa 公式 MCP サーバー |
| 対話エージェント | `agents/report-interviewer.md`（別ファイル） | SKILL.md 内に統合 |
| 環境変数 | 6 個（ESA_TEAM 等） | 不要（コネクタ認証） |
| スケジュール | hooks.json によるリマインダー | なし（Cowork の /schedule を利用可） |

### 共通ファイル

以下のファイルは両バリアントで同一の内容を使用する。変更時は **両方を更新** すること。

- `references/report-format.md` — 日報フォーマット定義
- `references/gaji-labo-style.md` — Gaji-Labo Style 行動規範リファレンス
