* ファイルの作成・更新やプログラムの実行を行う前に、必ずplanモードで計画を立てた後、 codex mcp を使用してレビューを行い、現在のタスクに基づいて作業計画を作成または更新すること。
* 実装作業の開始**直前**と完了**直後**に codex mcp を実行し、事前・事後レビューとして変更内容の検証と要約を行うこと。

## プロジェクトドキュメント

`.design/` ディレクトリにプロジェクトの設計ドキュメントが格納されています：

- `granddesign.md` - プロジェクトの全体設計
- `architecture.md` - アーキテクチャ設計
- `decisions.md` - 意思決定記録（ADR）
- `guidelines.md` - 開発ガイドライン
- `non-blocking-issues.md` - 非ブロッキング課題
- `tasks/` - タスク管理フォルダ

## タスク管理

### owner フィールド
タスクファイル（`.design/tasks/*.md`）の frontmatter `owner` で担当エージェントが指定される。
- `codex` — Codex が担当（sandbox内、限定変更）
- `claude-code` — Claude Code が担当（フル機能）
- 空 — 未トリアージ

### Claude Code の振る舞い
- `owner: codex` のタスクは実装しない（ユーザーが明示的に指示した場合を除く）
- `owner: claude-code` のタスクに着手可能
- `owner` が空のタスクを見つけた場合、まず AGENTS.md のトリアージ基準に従い owner を設定してから着手する
- タスク作成時は AGENTS.md のトリアージ基準に従い owner を必ず設定する
