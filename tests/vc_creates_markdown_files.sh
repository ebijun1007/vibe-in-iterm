#!/usr/bin/env bash
set -euo pipefail

# Verifies scripts/vc materializes AGENTS.md, CLAUDE.md, and todo.md as real files.

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_home="$(mktemp -d -t vc-test-home-XXXXXX)"
tmp_repo="$(mktemp -d -t vc-test-repo-XXXXXX)"
stub_bin="$(mktemp -d -t vc-test-bin-XXXXXX)"

cleanup() {
  rm -rf "$tmp_home" "$tmp_repo" "$stub_bin"
}
trap cleanup EXIT

if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude '.git' "$project_root"/ "$tmp_repo"/
else
  cp -R "$project_root"/. "$tmp_repo"/
fi

cat <<'STUB' > "$stub_bin/osascript"
#!/usr/bin/env bash
cat >/dev/null
exit 0
STUB
chmod +x "$stub_bin/osascript"

pushd "$tmp_repo" >/dev/null

chmod +x scripts/vc

rm -f AGENTS.md CLAUDE.md todo.md

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

missing=0
for file in AGENTS.md CLAUDE.md todo.md; do
  if [ ! -f "$file" ]; then
    echo "[fail] Expected $file to exist after running scripts/vc" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

if [ -L CLAUDE.md ]; then
  echo "[fail] CLAUDE.md should be a real Markdown file, not a symlink" >&2
  exit 1
fi

# Seed custom content and ensure vc preserves it on subsequent runs.
for file in AGENTS.md CLAUDE.md todo.md; do
  sentinel="existing content for ${file}"
  printf '%s\n' "$sentinel" > "$file"
  cp "$file" ".$file.expected"
done

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

for file in AGENTS.md CLAUDE.md todo.md; do
  if ! cmp -s ".$file.expected" "$file"; then
    echo "[fail] $file was modified even though it already existed" >&2
    exit 1
  fi
done

# Simulate the original symlinked CLAUDE.md and ensure vc leaves it untouched.
rm CLAUDE.md
ln -s AGENTS.md CLAUDE.md

PATH="$stub_bin:$PATH" \
TERM_PROGRAM="iTerm.app" \
HOME="$tmp_home" \
scripts/vc >/dev/null

if [ ! -L CLAUDE.md ]; then
  echo "[fail] CLAUDE.md symlink should not be replaced when it already exists" >&2
  exit 1
fi

popd >/dev/null

echo "[pass] scripts/vc created three Markdown files"
