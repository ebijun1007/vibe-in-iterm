---
name: review-code
description: 3エージェント並列でコードレビューを実行するオーケストレーター
user_invocable: true
triggers:
  - keyword: review-code
  - keyword: コードレビュー
---

# コードレビュースキル

コード変更を3つの視点（QA・Security・Code Consistency）で並列レビューし、結果を統合判定する。

## トリガー

- `/review-code` コマンド実行時
- `/close` の Step 2.5 から呼び出し時

## 入力

- `$TARGET_FILES`: レビュー対象のファイルリスト
- `$TASK_FILE`: 関連するタスクファイルパス（完了条件の照合用）

対象ファイルが指定されていない場合は、会話ログからこのセッションで作成・編集したファイルを特定する。タスクファイルが不明な場合はユーザーに確認する。

## 実行手順

### 1. 対象ファイルの確認

1. 対象ファイルが存在するか確認する
2. `git diff -- <対象ファイル>` で差分があるか確認する
3. 差分がない場合は総合判定 **PASS** として「レビュー対象の変更がありません（PASS）」と報告する。`/close` から呼び出された場合は Step 3 へ進む

### 2. 3エージェント並列レビュー

Agent ツールで以下の3エージェントを**並列**に起動する。各エージェントには対象ファイルリストとタスクファイルパスを渡す。

| エージェント | subagent_type | model | 指示 |
|-------------|--------------|-------|------|
| QA Reviewer | general-purpose | sonnet | `.claude/agents/qa-reviewer.md` の内容に従い、対象ファイル `$TARGET_FILES` をタスク `$TASK_FILE` の完了条件に照らしてレビューしてください |
| Security Reviewer | general-purpose | sonnet | `.claude/agents/security-reviewer.md` の内容に従い、対象ファイル `$TARGET_FILES` をレビューしてください |
| Code Consistency Reviewer | general-purpose | sonnet | `.claude/agents/code-consistency-reviewer.md` の内容に従い、対象ファイル `$TARGET_FILES` をレビューしてください |

**重要**: 3つの Agent ツール呼び出しを**同一メッセージ内で並列に**実行すること。

### 3. 結果の統合

3エージェントの結果を集約し、以下のフォーマットで統合レビュー結果を出力する：

```markdown
# コードレビュー結果（統合）

## 総合判定: [PASS / CONDITIONAL / REJECT]

[判定理由を1-2行で]

---

[各エージェントの出力をそのまま掲載]

---

## BLOCKING 指摘一覧（全エージェント分）
[BLOCKING があれば一覧化。なければ「なし」]

## WARNING 指摘一覧（全エージェント分）
[WARNING があれば一覧化。なければ「なし」]

## 推奨アクション
[次に取るべきアクションを箇条書き]
```

### 4. 総合判定ロジック

- 1つでも **REJECT** → 総合 **REJECT**
- REJECT なし + **CONDITIONAL** あり → 総合 **CONDITIONAL**
- 全 **PASS** → 総合 **PASS**

### 5. 後続処理との連携

このスキルの結果は `/close` の Step 2.5 で使用される：
- **PASS** → Step 3（Codex MCP レビュー）へ進む
- **CONDITIONAL** → WARNING を表示し、ユーザー承認で Step 3 へ
- **REJECT** → BLOCKING を表示し、修正を要求。解消まで Step 3 に進まない

Codex MCP レビュー（Step 3）はこのレビューとは独立して実施される（2段ゲート）。
