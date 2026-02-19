---
name: vibe-kanban-auto-restart
description: vibe-kanban の MCP 不整合（Failed to parse VK API response, 400 Bad Request など）が出たときに、ローカルアプリを再起動して疎通確認まで実施する。
---

# vibe-kanban 自動再起動

## 使うタイミング

以下の症状があるときに使う。

- `list_projects` が `Failed to parse VK API response` で失敗する
- `start_workspace_session` が `400 Bad Request` を返し続ける
- `project_id is required (not available from workspace context)` が頻発する
- vibe-kanban の更新直後に MCP の挙動が不安定

## 実行手順

1. まず現状確認を行う。
   - `mcp__vibe_kanban__list_repos`
   - `mcp__vibe_kanban__list_workspaces`
2. 再起動スクリプトを実行する。
   - `bash /Users/ebina/.codex/skills/vibe-kanban-auto-restart/scripts/restart_vibe_kanban.sh`
3. 再起動後に再確認する。
   - `mcp__vibe_kanban__list_projects`（可能なら）
   - `mcp__vibe_kanban__list_issues`（project_id 指定あり/なしを必要に応じて）
4. 直らない場合は `project_id` を手動指定して作業継続し、API不整合として記録する。

## 環境変数

- `VIBE_KANBAN_PORT` : 待ち受けポート（デフォルト: `55233`）
- `VIBE_KANBAN_APP_NAME` : `pkill -f` で停止対象にする文字列（デフォルト: `vibe-kanban`）
- `VIBE_KANBAN_START_CMD` : 起動コマンド（設定推奨）

`VIBE_KANBAN_START_CMD` 未設定時は macOS の `open -a` を試行する。

## 安全ルール

- リモートIssueやプロジェクトの削除は行わない。
- workspace 削除はユーザー明示指示がある場合のみ行う。
- 不整合時は推測で再作成せず、まず再起動でバージョン差異を疑う。
