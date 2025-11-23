# Cursor + Vibe Kanban Workspace with `vc`

`vc` is a small helper script for working in **Cursor** while keeping your tasks in **vibe-kanban**. It bootstraps the workspace files/templates you need, starts the kanban board on its default port, and primes your local environment for agent work.

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

### 2. Reload your shell configuration

```bash
source ~/.zshrc  # or source ~/.bashrc
```

---

## 🚀 Usage

From any project directory, run:

```bash
vc
```

The command will prepare the workspace and create an iTerm layout with coding agents.

---

## 🧠 What `vc` does

- Copies templates (`.codex`, `.claude`, `.design`, `todo.md`, `issues.md`, `refactor.json`) into the current directory without overwriting existing files
- Adds common local files to `.gitignore` so they stay out of commits
- Touches `todo.md` and opens it in Cursor/VS Code when the `code` CLI is installed
- Creates an iTerm layout with 3 panes: codex (top-left), claude (top-right), and terminal (bottom)

---

## 📁 Files and Directories Modified by Commands

### `setup.sh` Command

When you run `bash setup.sh`, the following files and directories are created or modified:

| Path | Action | Description |
|------|--------|-------------|
| `~/bin/` | Created | Directory for user commands |
| `~/bin/vc` | Created/Overwritten | vc command installation |
| `~/.zshrc` or `~/.bashrc` | Modified | Adds `~/bin` to PATH (if not present) |
| `~/Library/Application Support/ai.bloop.vibe-kanban/` | Created | vibe-kanban data directory |
| `~/Library/Application Support/ai.bloop.vibe-kanban/profiles.json` | Created/Overwritten | Copied from repo root |

### `vc` Command

When you run `vc` from any project directory, the following files and directories are created or modified:

| Path | Action | Description |
|------|--------|-------------|
| `$WORKDIR/.gitignore` | Modified | Adds entries: `.claude`, `.codex`, `.design`, `refactor.json`, `issues.md`, `todo.md` |
| `$WORKDIR/todo.md` | Created | Empty file created and opened in VS Code (only if missing) |
| `$WORKDIR/*` | Created | Template files copied from `templates/` directory (only if missing, no overwrite) |

> **Note:** `$WORKDIR` refers to the current working directory where you execute the `vc` command.

---

## 📦 Project Structure

```
.
├── scripts/
│   └── vc            # Main vc command script
├── setup.sh          # Installer for vc and helper CLIs
├── profiles.json     # vibe-kanban profiles copy source
├── templates/        # Workspace templates (codex/claude/design/todo/issues)
└── README.md
```

---

## 🧩 Customization

Edit `scripts/vc` to adjust defaults such as the workspace templates directory or the commands launched for your agents. After editing, rerun `bash setup.sh` to reinstall the updated script into `~/bin`.

---

**Requirements:**
- macOS with iTerm.app
- VS Code CLI (`code`) if you want `todo.md` to open automatically
- Agent CLIs you plan to run (e.g., `codex`, `claude`)
