---
name: review-req
description: 3エージェント並列で要件レビューを実行するオーケストレーター
user_invocable: true
triggers:
  - keyword: review-req
  - keyword: 要件レビュー
---

# 要件レビュースキル

タスクファイルの要件を3つの視点（PdM・Tech Lead・UX Designer）で並列レビューし、結果を統合判定する。

## トリガー

- `/review-req` コマンド実行時
- `/pick` の Step 2.5 から呼び出し時

## 入力

- `$TASK_FILE`: レビュー対象のタスクファイルパス（`.design/tasks/YYYYMMDD-*.md`）

タスクファイルが指定されていない場合は、ユーザーに対象タスクファイルを確認する。

## 実行手順

### 1. タスクファイルの検証

1. タスクファイルが存在するか確認する
2. `## 概要` と `## 完了条件` セクションが存在するか確認する
3. 不備がある場合はユーザーに報告して終了する

### 2. 3エージェント並列レビュー

Agent ツールで以下の3エージェントを**並列**に起動する。各エージェントにはタスクファイルのパスを渡す。

| エージェント | subagent_type | model | 指示 |
|-------------|--------------|-------|------|
| PdM Reviewer | general-purpose | sonnet | `.claude/agents/pdm-reviewer.md` の内容に従い、タスクファイル `$TASK_FILE` をレビューしてください |
| Tech Lead Req Reviewer | general-purpose | sonnet | `.claude/agents/techlead-req-reviewer.md` の内容に従い、タスクファイル `$TASK_FILE` をレビューしてください |
| UX Reviewer | general-purpose | sonnet | `.claude/agents/ux-reviewer.md` の内容に従い、タスクファイル `$TASK_FILE` をレビューしてください |

**重要**: 3つの Agent ツール呼び出しを**同一メッセージ内で並列に**実行すること。

### 3. 結果の統合

3エージェントの結果を集約し、以下のフォーマットで統合レビュー結果を出力する：

```markdown
# 要件レビュー結果（統合）

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
