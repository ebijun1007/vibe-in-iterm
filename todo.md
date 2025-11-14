Status: Ready

## Assumptions
- The `vc` command must bootstrap `AGENTS.md`, `CLAUDE.md`, and `todo.md` only when they are missing; if a user already has content, the command must not overwrite, truncate, or re-touch those files.
- Even legacy symlinks (e.g., `CLAUDE.md -> AGENTS.md`) count as "existing" and must not be replaced automatically — creation happens only for truly missing paths.

## Implementation Plan
- [x] **Pre-flight bootstrap in `scripts/vc`.** Before invoking `osascript`, loop over the markdown filenames and create them only when `[ ! -e "$file" ]` — no removal/recreation of existing symlinks or files.
- [x] **Idempotent logging.** Track whether any files were created during the bootstrap and emit `[info] Created …` only when new files were added; emit `[info] Markdown files already present` otherwise so users can tell no overwrites occurred.
- [x] **Preserve runtime behavior.** Leave the AppleScript / watcher logic unchanged so the panes continue behaving identically; the only side effect should be the pre-flight creation when necessary.
- [x] **Documentation update.** Refresh `README.md` (usage section + customization note) to emphasize that `vc` now ensures the markdown files exist without modifying existing content.

## Test Plan
- [x] `bash tests/vc_creates_markdown_files.sh`
  - Stubs `osascript`, runs `scripts/vc`, and verifies both file creation and preservation of existing content/symlinks.

## Implementation Notes
- Updated `scripts/vc:13-26` to use `[ ! -e "$file" ]` check, which preserves both regular files and symlinks
- Added array tracking for created files with conditional logging: "[info] Created X Y Z" vs "[info] Markdown files already present"
- Test suite enhanced to verify: (1) missing files are created, (2) existing content is preserved on re-runs, (3) symlinks (e.g., `CLAUDE.md -> AGENTS.md`) remain untouched
- All tests pass successfully, confirming idempotent behavior with zero overwrites
