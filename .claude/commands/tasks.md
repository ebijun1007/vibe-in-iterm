---
name: tasks
description: .design/tasks/ フォルダ内のタスク一覧を表示し、選択されたタスクの詳細を読み込むコマンド
---
`.design/tasks/` フォルダ内のタスクファイル一覧を表示し、ユーザーが選択したタスクの詳細を読み込みます。

## 実行手順

### Step 1: タスク一覧の表示
1. `.design/tasks/` フォルダ内の `YYYYMMDD-*.md` ファイルを一覧取得（README.md は除外）
2. ファイル名のみを一覧表示（中身は読み込まない）

### Step 2: タスク選択
ユーザーにどのタスクに着手するか確認する。AskUserQuestion ツールを使用して選択肢を提示。

### Step 3: 詳細読み込み
選択されたタスクファイルのみを読み込み、内容を表示する。

## 出力形式（Step 1）

```
## タスク一覧
1. 20260117-fix-login.md
2. 20260118-add-export.md
3. 20260115-refactor-api.md

どのタスクに着手しますか？
```

## 備考

- 命名規則: `YYYYMMDD-title.md`（例: `20260117-fix-login.md`）
- テンプレートは `.design/tasks/README.md` を参照
- 旧 `/todo` コマンドは廃止されました
