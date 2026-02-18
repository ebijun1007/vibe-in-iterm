# タスク管理

このフォルダでは個別タスクを独立した markdown ファイルで管理します。
.design/tasks を正本とし、起票時に vibe-kanban へ同時起票します。

## 命名規則

`YYYYMMDD-title.md`（例: `20260117-fix-login.md`）

- 日付は作成日を使用
- title は英語のケバブケースで簡潔に記述

## テンプレート

```markdown
# [タスクタイトル]

## ステータス
- [ ] 未着手 / [x] 進行中 / [x] 完了

## owner
codex または claude-code

## 概要
[タスクの説明]

## 完了条件
- [ ] 条件1
- [ ] 条件2

## vibe-kanban同期
- カードID: [起票後に記載]
- 同期状態: [synced / pending / error]
- 最終同期: [YYYY-MM-DD HH:MM]

## 備考
[必要に応じて追記]
```

## 使い方

### 新規タスクの作成
1. このフォルダに `YYYYMMDD-title.md` 形式でファイルを作成
2. `owner` を `codex` または `claude-code` で明記
3. 上記テンプレートに従って内容を記述
4. 同時に vibe-kanban に同内容でカードを作成し、カードIDを `## vibe-kanban同期` に記録

### タスクの確認
`/tasks` コマンドでこのフォルダ内のタスクを一覧・確認できます。

### 完了したタスク
完了したタスクファイルは削除するか、`completed/` サブフォルダに移動してアーカイブできます。
