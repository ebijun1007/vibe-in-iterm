# vibe-kanban 実行テンプレート

このテンプレートは `task-intake` / `attempt` 実行時に毎回埋める。
未記入項目がある場合は処理を止めてユーザー確認する。

## 0. 事前確認

- [ ] 作業ディレクトリ名 (`pwd` basename): `________________`
- [ ] MCP接続先: `http://127.0.0.1:55233`（固定、変更時のみ `VIBE_KANBAN_PORT`）
- [ ] `.design/tasks` 対象ファイル: `________________`
- [ ] `owner` (`codex` / `claude-code`): `________________`
- [ ] `カードID`（未作成なら空欄）: `________________`
- [ ] `タイトル`: `________________`
- [ ] `description 用本文`: タスクファイルからタイトル行（`# ...`）と `## vibe-kanban同期` セクションを除いた残り全文

## 1. プロジェクト特定

1. `list_projects` を実行
2. project 名が `pwd` basename と**完全一致**するものを選ぶ

記録:
- [ ] `project_id`: `________________`
- [ ] 一致件数が1件（YES/NO）: `____`

判定:
- 一致0件: ユーザー確認のうえ `create_project`
- 一致2件以上: 推測禁止。ユーザー確認

## 2. 起票/更新同期（.design/tasks が正本）

### 2-A. 新規起票（カードIDなし）

前提:
- [ ] `カードID` が空欄

実行:
1. `create_task(project_id, title, description, status?)`
   - `description`: タスクファイルの markdown 本文をそのまま渡す（タイトル行 `# ...` と `## vibe-kanban同期` セクションを除く）
2. 戻り値 `id` を `.design/tasks` の `カードID` に記録

記録:
- [ ] `task_id`: `________________`
- [ ] `同期状態`: `synced`
- [ ] `最終同期`: `YYYY-MM-DD HH:MM`

### 2-B. 更新同期（カードIDあり）

前提:
- [ ] `カードID` が存在

実行:
1. `get_task(task_id)` で存在確認
2. `update_task(task_id, title?, description?, status?)`
   - `description`: タスクファイルの markdown 本文をそのまま渡す（タイトル行 `# ...` と `## vibe-kanban同期` セクションを除く）

記録:
- [ ] `task_id`: `________________`
- [ ] `同期状態`: `synced`
- [ ] `最終同期`: `YYYY-MM-DD HH:MM`

エラー時:
- [ ] `.design/tasks` の `同期状態: error` へ更新
- [ ] エラー理由を備考へ記録

## 3. ステータス更新の安全運用

1. `list_tasks(project_id)` または `get_task(task_id)` で既存 status 値を確認
2. 観測した値のみ使用

チェック:
- [ ] 使用する status は観測済み値
- [ ] 未観測なら status 更新をスキップ（タイトル/説明のみ同期）

## 4. attempt 開始（ユーザーが実装着手を要求した時のみ）

### 4-A. executor 決定

- [ ] `owner: codex` -> `executor: codex`
- [ ] `owner: claude-code` -> `executor: claude-code`
- [ ] `executor: codex` の場合は `.codex/prompts/codex-implementation.md` を適用

記録:
- [ ] `executor`: `________________`

### 4-B. repos 収集

1. `list_repos(project_id)` を実行
2. 対象 repos を決定
3. 各 repo の `base_branch` を決定

`base_branch` 優先順:
1. タスク本文で明示されたブランチ
2. 現在ブランチ
3. 不明ならユーザー確認

記録:
- [ ] `repos`: `[{"repo_id":"...","base_branch":"..."}]`

### 4-C. セッション開始

1. `start_workspace_session(task_id, executor, repos)` を実行

記録:
- [ ] セッション開始結果: `success / failure`
- [ ] 失敗時エラー内容: `________________`

## 5. 最終チェック

- [ ] `.design/tasks` と vibe-kanban のタイトルが一致
- [ ] `.design/tasks` と vibe-kanban の description がタスクファイル本文と一致
- [ ] `カードID` が `.design/tasks` に記録済み
- [ ] `同期状態` / `最終同期` が更新済み
