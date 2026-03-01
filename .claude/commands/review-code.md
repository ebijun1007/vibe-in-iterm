---
description: コード変更を QA・Security・Code Consistency の3視点で並列レビューするコマンド
---

指定されたファイルのコードレビューを実行します。

## 使い方

```
/review-code [対象ファイル...]
```

対象ファイルが指定されない場合は、会話ログからこのセッションで変更したファイルを自動検出します。

## 実行内容

review-code スキルを呼び出し、以下の3エージェントによる並列コードレビューを実行します：

1. **QA Reviewer**: 機能正確性・エッジケース・テストカバレッジ・リグレッションリスク
2. **Security Reviewer**: OWASP Top 10・入力検証・認証認可・機密情報露出
3. **Code Consistency Reviewer**: 命名規則・DRY原則・設計パターン遵守

結果は統合判定（PASS / CONDITIONAL / REJECT）として報告されます。
