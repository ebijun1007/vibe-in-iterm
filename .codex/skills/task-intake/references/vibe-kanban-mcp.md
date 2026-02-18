# vibe-kanban MCP 呼び出し規約

この規約は `https://www.vibekanban.com/docs/integrations/vibe-kanban-mcp-server` の仕様に基づく。

## 利用可能ツール

- `list_projects`
- `create_project`
- `list_repos`
- `create_repo`
- `list_tasks`
- `create_task`
- `get_task`
- `update_task`
- `delete_task`
- `start_workspace_session`

## 必須パラメータ

- `list_tasks`: `project_id`（任意: `status`, `limit`）
- `create_task`: `project_id`, `title`（任意: `description`）
- `get_task`: `task_id`
- `update_task`: `task_id`（任意: `title`, `description`, `status`）
- `delete_task`: `task_id`
- `list_repos`: `project_id`
- `start_workspace_session`: `task_id`, `executor`, `repos`（任意: `variant`）

`repos` は配列で、各要素は以下:
- `repo_id`
- `base_branch`

## 共通ルール

1. まず `list_projects` を呼び、作業ディレクトリ名 (`pwd` の basename) と同名のプロジェクトを探す。
2. 同名プロジェクトが1件ならそれを使用する。
3. 見つからない場合はユーザーに確認して `create_project` する。
4. 複数一致した場合は推測せずユーザーに確認する。

## タスク同期ルール（.design/tasks が正本）

1. `.design/tasks/*.md` に `カードID` がある場合:
   - `get_task(id)` で存在確認
   - `update_task(id, ...)` で同期
2. `カードID` がない場合:
   - `create_task(project_id, title, description, status)` で作成
   - 返却 `id` をタスクファイルへ記録
3. 同期失敗時:
   - `.design/tasks` に `同期状態: error` を記録し、理由を報告する

## attempt 開始ルール

1. `owner` から `executor` を決める:
   - `owner: codex` -> `executor: codex`
   - `owner: claude-code` -> `executor: claude-code`
2. `list_repos(project_id)` で repo 候補を取得し `repos` を構築する。
3. `start_workspace_session(task_id, repos, executor)` を呼ぶ。
4. base_branch は次の優先順で決める:
   - タスク本文に明示されたブランチ
   - 現在ブランチ
   - どちらも無い場合はユーザー確認

## ステータス更新ルール

1. ステータス値を推測しない。
2. 対象プロジェクトの既存 `list_tasks` / `get_task` で確認できた値だけ使用する。
3. 対応表が確定できない場合は、タイトル・説明のみ更新し、ステータスは変更しない。
