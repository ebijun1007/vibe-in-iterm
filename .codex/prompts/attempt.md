---
name: Attempt
description: タスク着手時に owner に応じて実行エージェントを選び、着手状態に更新して開始する
author: codex
---

## Goal

`.design/tasks/` のタスクを着手状態にし、`owner` に応じて attempt の対象エージェントを分岐する。

## Process

### 1. 対象タスクの特定

1. 対象の `.design/tasks/YYYYMMDD-*.md` を読み込む
2. `## owner` を確認する（`codex` または `claude-code`）
3. タスクの概要・完了条件を確認する

### 2. owner から attempt エージェントを決定

1. `owner: codex` の場合:
   - attempt エージェントは `codex`
2. `owner: claude-code` の場合:
   - attempt エージェントは `claude-code`

### 3. 着手処理

1. タスクの `## ステータス` を `進行中` に更新する
2. 作業対象のファイル・完了条件を再確認する

### 4. 実装担当の分岐

1. `owner: codex`:
   - このセッションで実装を継続する
   - 実装時は `.codex/prompts/codex-implementation.md` の方針を適用する
2. `owner: claude-code`:
   - このセッションでは実装しない
   - `claude-code` に引き継ぐための必要情報（対象タスク、完了条件）を報告する

## Guardrails

- owner が未記載、または `codex` / `claude-code` 以外なら処理を停止してユーザー確認する
- `.design/tasks` を正本とし、タスクファイルの情報に従って進める
