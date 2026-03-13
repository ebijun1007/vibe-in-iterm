---
name: Close Task
description: 着手中タスクのセルフレビュー・コミット・完了処理を一括で行うプロンプト
author: codex
---

## Goal

現在着手中（進行中）のタスクに対して、セルフレビュー → コミット（タスク更新含む） → 必要に応じた後続タスク起票を一連で行う。

## Important override for this run

AGENTS.md の編集制限を、このタスク完了処理に必要な範囲で解除する：
- `.design/tasks/` 内のタスクファイル（ステータス更新）
- `.design/non-blocking-issues.md`（DEFERRED項目の追記）
- `.design/tasks/` への新規タスクファイル作成（ユーザー承認後のみ）

## Process

### 1. 着手中タスクの特定

1. **会話ログを確認**し、この会話セッション中に pick プロンプト等で着手したタスク、またはユーザーが言及・作業していたタスクを特定する
2. 会話ログから特定できない場合は、ユーザーにどのタスクを完了させるか確認する
3. 対象タスクの `.design/tasks/YYYYMMDD-*.md` ファイルを読み込み、完了条件を把握する

### 2. 対象ファイルの特定

1. **会話ログから、自分がこのセッション中に作成・編集したファイルの一覧を確認する**
2. そのファイル一覧のみを対象とする。他の並行作業による差分は**無視する**
3. `git diff` は対象ファイルに絞って確認する（例: `git diff -- <file1> <file2> ...`）
4. 対象外のファイルについて確認や言及をしない。止まらずに進める

### 3. セルフレビュー

変更差分を以下の4観点でレビュー：
- **correctness** / **tests** / **design** / **style**
- 設計ドキュメント（`.design/architecture.md`、`.design/guidelines.md`）との整合性を確認

分類：
- **BLOCKING**: コミット前に修正必須 → コミットせず問題を報告して終了
- **QUICK-FIX**: 小規模・局所的 → この場で修正してコミット
- **DEFERRED**: 大規模・横断的 → `.design/non-blocking-issues.md` に記録

### 4. コミット（タスク更新を含む）

1. QUICK-FIX があれば先に修正を適用
2. タスクファイルのステータスを更新：`[x] 進行中` → `[ ] 進行中`、`[ ] 完了` → `[x] 完了`
3. 達成済みの完了条件にチェックを入れる
4. タスク関連ファイル＋タスクファイル自体をまとめてステージ（`git add .` 禁止）
5. HEREDOC形式で **単一コミット** として実行：

```bash
git add <files...> <task-file> && \
git commit -m "$(cat <<'EOF'
短い要約

- 詳細1
- 詳細2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

6. push しない

### 5. 後続タスク・懸念事項

- DEFERRED: `.design/non-blocking-issues.md` に追記
- 新規タスク: **ユーザー確認の上**、`.design/tasks/YYYYMMDD-title.md` で起票（テンプレートは `.design/tasks/README.md` に準拠）

### 6. 完了報告

- 対象タスク名、コミット要約、QUICK-FIX/DEFERRED/後続タスクの一覧を報告

## Guardrails

- リモートへ push しない
- BLOCKING問題がある場合はファイル変更・コミットを行わない
- コミット失敗時はタスクステータスを更新しない
- 新規タスクの自動起票は禁止（必ずユーザー確認）
