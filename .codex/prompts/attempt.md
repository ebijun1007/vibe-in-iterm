---
name: Attempt
description: タスク着手時に owner に応じて実行エージェントを選び、vibe-kanban と同期して開始する
author: codex
---

## Goal

`.design/tasks/` のタスクを着手状態にし、`owner` に応じて attempt の対象エージェントを分岐する。あわせて vibe-kanban 側のカード状態も同期する。

## Process

### 1. 対象タスクの特定

1. 対象の `.design/tasks/YYYYMMDD-*.md` を読み込む
2. `## owner` を確認する（`codex` または `claude-code`）
3. `## vibe-kanban同期` からカードIDを取得する
4. `list_projects` を呼び、`pwd` basename と一致する project を特定する

### 2. owner から attempt エージェントを決定

1. `owner: codex` の場合:
   - attempt エージェントは `codex`
2. `owner: claude-code` の場合:
   - attempt エージェントは `claude-code`

### 3. 着手処理

1. タスクの `## ステータス` を `進行中` に更新する
2. `list_repos(project_id)` で repos を収集する
3. `start_workspace_session(task_id, repos, executor)` を呼び、vibe-kanban MCP で同一カードを attempt 開始状態にする
   - エージェント指定は手順2の結果を使う
4. `## vibe-kanban同期` の `同期状態` と `最終同期` を更新する

### 4. 実装担当の分岐

1. `owner: codex`:
   - このセッションで実装を継続する
   - 実装時は `.codex/prompts/codex-implementation.md` の方針を適用する
2. `owner: claude-code`:
   - このセッションでは実装しない
   - `claude-code` に引き継ぐための必要情報（対象タスク、完了条件、カードID）を報告する

## Guardrails

- owner が未記載、または `codex` / `claude-code` 以外なら処理を停止してユーザー確認する
- カードIDが無い場合は、attempt 前に vibe-kanban へカードを作成してIDを記録する
- `.design/tasks` を正本とし、差異がある場合は vibe-kanban 側を合わせる
- project が一意に特定できない場合は推測せずユーザー確認する
