# iTerm 4-Pane Layout with `vc` Command

This repository provides a **`vc` command** that sets up an **iTerm2 four-pane layout** in any directory.

**Layout:**
- **Left pane:** watches `todo.md` (auto-created if missing)
- **Top-right:** runs `codex`
- **Middle-right:** runs `claude --dangerously-skip-permissions`
- **Bottom-right:** opens a normal shell in the same directory

Existing iTerm tabs are preserved — a new tab is created for the layout.

---

## ⚙️ Setup

### 1. Clone this repository and run the setup script

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
bash setup.sh
```

This will:
- Install the `vc` command to `~/bin`
- Add `~/bin` to your `PATH` if needed
- Put everything in place so the `vc` command can bootstrap the workspace Markdown files on demand

### 2. Reload your shell configuration

```bash
source ~/.zshrc  # or source ~/.bashrc
```

---

## 🚀 Usage

Navigate to any directory where you want to work, then run:

```bash
vc
```

iTerm will create a new tab with 4 panes as described above.

The `vc` command creates `AGENTS.md`, `CLAUDE.md`, and `todo.md` only when they are missing before launching the layout. Existing files (including any local symlink choices) remain untouched so your notes are never overwritten.

---

## 🧠 How It Works

1. The `vc` command is a shell script installed in `~/bin`
2. When executed, it:
   - Detects the current working directory
   - Ensures `AGENTS.md`, `CLAUDE.md`, and `todo.md` exist (creating only missing files)
   - Runs AppleScript to create a new iTerm tab with 4 panes
   - Sets up each pane with the appropriate command

---

## 📦 Project Structure

```
.
├── scripts/
│   └── vc            # The vc command script
├── setup.sh          # Setup script
├── AGENTS.md         # Agent configuration
├── CLAUDE.md         # Claude-specific notes
└── todo.md           # Shared task list surfaced in iTerm
```

---

## 🧩 Customization

To change the commands for each pane, edit `scripts/vc` before running `setup.sh`, or directly edit `~/bin/vc` after installation.

Look for these sections in the AppleScript:
```applescript
-- left pane: watch todo.md
write text "cd " & workdir & "; [ ! -f todo.md ] && touch todo.md; while true; do clear; cat todo.md; sleep 1; done"

-- top-right: run codex
write text "cd " & workdir & "; codex"

-- middle-right: run claude
write text "cd " & workdir & "; claude --dangerously-skip-permissions"

-- bottom-right: shell
write text "cd " & workdir
```

---

**Requirements:**
- macOS with iTerm2
- The commands you want to run in each pane (`codex`, `claude`, etc.)
