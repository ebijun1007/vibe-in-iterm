---
name: task-resync
description: Re-sync `.design/tasks` with vibe-kanban after pulling the current branch. Use when tasks drift between local git state and vibe-kanban.
---

# Task Resync

## 目的

`git pull` 後に `.design/tasks` と vibe-kanban の差分を解消する。
正本は常に `.design/tasks`。

## Workflow

1. 現在ブランチを確認する（`git rev-parse --abbrev-ref HEAD`）。
2. 現在ブランチを pull する（`git pull --rebase`）。
3. `.design/tasks/README.md` を読み、タスクフォーマットを確認する。
4. `.design/tasks/*.md` を列挙し、各ファイルの次を取得する。
   - タイトル
   - 概要
   - owner
   - `## vibe-kanban同期` の `カードID` / `同期状態` / `最終同期`
5. vibe-kanban の対象プロジェクトを特定する。
   - プロジェクト名は `pwd` basename と完全一致。
   - 一意に決まらない場合は推測せずユーザー確認。
6. 各タスクを同期する（`.design/tasks` が正本）。
   - `カードID` あり: `get_task` で存在確認し、`update_task` で同期。
   - `カードID` なし: `create_task` で新規作成し、返却 ID をファイルへ記録。
7. 同期結果をローカルへ反映する。
   - 成功: `同期状態: synced` と `最終同期` を更新。
   - 失敗: `同期状態: error` を記録し、`備考` に失敗理由を追記。
8. 必要なら同期結果の変更を commit する（ユーザー指示がある場合のみ）。

## 安全ルール

- ステータス値は推測しない。既存タスクで観測済みの値のみ使う。
- ステータス対応が不明なら、タイトル・説明のみ同期してユーザー確認。
- `カードID` があるのに `get_task` で見つからない場合は勝手に再作成しない。ユーザー確認。
- 実装着手（`start_workspace_session`）は明示依頼がある場合のみ実行。

## 出力

- 同期対象ファイル数
- 更新件数（update/create/error）
- `error` の一覧（ファイル名と理由）
- 実行した pull コマンドと対象ブランチ
