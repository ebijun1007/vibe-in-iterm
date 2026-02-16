---
name: setup-env
description: 1Passwordを使った開発環境のセットアップを支援するスキル。「setup」「セットアップ」「環境構築」「1password」「op」「新しいPC」「環境同期」「aws config」「credentials」「認証情報」などのキーワードで発動。プロジェクトの scripts/setup-env.sh を検出・実行し、1Password から認証情報を復元する。
---

# setup-env スキル

1Password を使って開発環境の認証情報をセットアップする。プロジェクトごとの `scripts/setup-env.sh` を検出・実行する。

## 前提

- 1Password アプリがインストール済みで、CLI 連携が有効
- 1Password CLI (`op`) がインストール済み
- 認証情報は 1Password のセキュアノートとして保存済み

## 動作フロー

### 1. 前提チェック

```bash
command -v op && op vault list
```

失敗した場合は以下を案内:
- 1Password アプリの **設定 > 開発者 > CLI連携** を有効にする
- `brew install 1password-cli` でインストール

### 2. セットアップスクリプトの検出

プロジェクトルートで `scripts/setup-env.sh` を探す。

- **存在する場合**: スクリプトの内容を確認し、ユーザーに実行を提案する
- **存在しない場合**: プロジェクトに `.envrc` や環境変数の参照があるか調査し、`scripts/setup-env.sh` の作成を提案する

### 3. スクリプトの実行

ユーザーが同意した場合のみ実行:

```bash
./scripts/setup-env.sh
```

### 4. 動作確認

セットアップ完了後、プロジェクト固有の検証コマンドを実行:

```bash
# AWS プロファイルが設定された場合
aws sts get-caller-identity --profile <profile_name>

# direnv が設定された場合
direnv allow
```

## セットアップスクリプトの設計指針

新規に `scripts/setup-env.sh` を作成する場合は以下に従う:

- `set -euo pipefail` を冒頭に記述
- `op item get` で vault を明示指定（`--vault` フラグ）
- 1Password からの値取得を **config 変更前に完了** する（取得失敗で既存設定が壊れないよう）
- フィールド名の推測フォールバックは禁止（不一致時はエラー終了）
- 既存設定がある場合は対話確認 → バックアップ（`chmod 600`）→ 上書き
- 非対話環境では上書きをスキップ

## 注意事項

- スクリプトの自動実行はしない。必ずユーザーの同意を得てから実行する。
- `.design/setup-guide.md` が存在する場合はそちらも参照するよう案内する。
