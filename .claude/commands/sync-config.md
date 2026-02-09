# sync-config: ローカル設定を vibe-coding リポジトリに同期

ローカルの `~/.claude/` と `~/.codex/` の設定ファイルを GitHub の `ebijun1007/vibe-coding` リポジトリに同期する。

## 同期対象

### `.claude/`
- `~/.claude/CLAUDE.md` → `.claude/CLAUDE.md`
- `~/.claude/settings.json` → `.claude/settings.json`
- `~/.claude/commands/*.md` → `.claude/commands/*.md` (既存削除後に全コピー)
- `~/.claude/skills/*/SKILL.md` → `.claude/skills/*/SKILL.md`
- `~/.claude/hooks/.keep` → `.claude/hooks/.keep` (維持)

### `.codex/`
- `~/.codex/AGENTS.md` → `.codex/AGENTS.md`
- `~/.codex/prompts/*.md` → `.codex/prompts/*.md`
- `~/.codex/skills/*/SKILL.md` → `.codex/skills/*/SKILL.md` (`.system/` 除外)
- `~/.codex/skills/.system/**` → `.codex/skills/.system/**` (ディレクトリ丸ごと)

### 除外対象 (コピーしない)
- `~/.codex/sessions/`, `auth.json`, `config.toml`, `log/`, `version.json` などの個人・環境固有ファイル
- `~/.claude/projects/` (プロジェクト固有メモリ)
- `.design/` (vibe-coding リポジトリ側で直接管理)

## 実行手順

以下のステップを順番に実行すること:

### Step 1: vibe-coding リポジトリの準備

```bash
cd /Users/ebijun/workdir/vibe-in-iterm
```

リポジトリが存在することを確認し、作業ツリーの状態をチェック:

```bash
git -C /Users/ebijun/workdir/vibe-in-iterm status --porcelain
```

もし未コミットの変更がある場合は、ユーザーに報告して続行するか確認する。

最新を取得:

```bash
git -C /Users/ebijun/workdir/vibe-in-iterm fetch origin && git -C /Users/ebijun/workdir/vibe-in-iterm pull --ff-only origin master
```

pull に失敗した場合はユーザーに報告して中断する。

### Step 2: ファイルのコピー

以下のコマンドを順番に実行する。すべて bash で実行すること。

**注意**: パスの `~` は `$HOME` に展開して使用する。

#### .claude/ のコピー

```bash
# CLAUDE.md と settings.json
cp "$HOME/.claude/CLAUDE.md" /Users/ebijun/workdir/vibe-in-iterm/.claude/CLAUDE.md
cp "$HOME/.claude/settings.json" /Users/ebijun/workdir/vibe-in-iterm/.claude/settings.json

# commands/ - 既存の .md を削除してから全コピー
rm -f /Users/ebijun/workdir/vibe-in-iterm/.claude/commands/*.md
cp "$HOME/.claude/commands/"*.md /Users/ebijun/workdir/vibe-in-iterm/.claude/commands/

# skills/ - 各スキルの SKILL.md をコピー (ディレクトリ構造を維持)
for skill_dir in "$HOME/.claude/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "/Users/ebijun/workdir/vibe-in-iterm/.claude/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "/Users/ebijun/workdir/vibe-in-iterm/.claude/skills/$skill_name/SKILL.md" 2>/dev/null || true
done

# hooks/.keep を維持
touch /Users/ebijun/workdir/vibe-in-iterm/.claude/hooks/.keep
```

#### .codex/ のコピー

```bash
# AGENTS.md
cp "$HOME/.codex/AGENTS.md" /Users/ebijun/workdir/vibe-in-iterm/.codex/AGENTS.md

# prompts/ - 既存の .md を削除してから全コピー
rm -f /Users/ebijun/workdir/vibe-in-iterm/.codex/prompts/*.md
cp "$HOME/.codex/prompts/"*.md /Users/ebijun/workdir/vibe-in-iterm/.codex/prompts/

# skills/ - .system/ 以外の各スキルの SKILL.md
for skill_dir in "$HOME/.codex/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = ".system" ] && continue
  mkdir -p "/Users/ebijun/workdir/vibe-in-iterm/.codex/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "/Users/ebijun/workdir/vibe-in-iterm/.codex/skills/$skill_name/SKILL.md" 2>/dev/null || true
done

# .system/ ディレクトリを丸ごと同期 (rsync で削除含む)
rsync -a --delete "$HOME/.codex/skills/.system/" /Users/ebijun/workdir/vibe-in-iterm/.codex/skills/.system/
```

### Step 3: 差分の確認

コピー完了後、差分をユーザーに表示:

```bash
git -C /Users/ebijun/workdir/vibe-in-iterm diff
git -C /Users/ebijun/workdir/vibe-in-iterm status
```

差分の内容をユーザーに分かりやすく要約して表示する。

**セキュリティチェック**: diff の中に秘密情報 (API キー、トークン、パスワード等) が含まれていないことを確認する。疑わしい内容があればユーザーに警告する。

### Step 4: ユーザー確認

差分を表示した後、ユーザーに「この内容でコミット＆プッシュしてよいか？」を確認する。

### Step 5: コミット＆プッシュ

ユーザーが承認した場合のみ実行:

```bash
cd /Users/ebijun/workdir/vibe-in-iterm
git add .claude/ .codex/
git commit -m "sync: update config files from local environment"
git push origin master
```

変更がない場合（diff が空の場合）は「同期済み、変更なし」と報告して終了する。

### 完了報告

push が成功したらユーザーに完了を報告する。失敗した場合はエラー内容を表示する。
