---
name: sync-config
description: ~/.claude/ や ~/.codex/ の設定ファイル (CLAUDE.md, settings.json, commands/*.md, skills/*/SKILL.md, AGENTS.md, prompts/*.md, skills/.system/**) を編集・作成・削除した際に、vibe-coding リポジトリへの同期を提案するスキル。
---

# sync-config スキル

`~/.claude/` または `~/.codex/` 配下の設定ファイルを編集した後、vibe-coding リポジトリへの同期を提案する。

## トリガー条件

以下のファイルを **編集・作成・削除** した場合にこのスキルが発動する:

### ~/.claude/
- `CLAUDE.md`
- `settings.json`
- `commands/*.md`
- `skills/*/SKILL.md`

### ~/.codex/
- `AGENTS.md`
- `prompts/*.md`
- `skills/*/SKILL.md`
- `skills/.system/**`

## 動作

設定ファイルの編集が完了した後、以下のメッセージをユーザーに表示する:

> 設定ファイルが更新されました。`/sync-config` を実行して vibe-coding リポジトリに同期しますか？

ユーザーが同意した場合のみ `/sync-config` コマンドを実行する。自動実行はしない。

## 注意事項

- このスキルは **提案のみ** を行う。同期の実行判断はユーザーに委ねる。
- 複数ファイルを連続で編集している場合は、すべての編集が終わってからまとめて1回提案する。
- `/sync-config` コマンド内で差分確認・セキュリティチェックが行われるため、このスキルでは重複チェックしない。
