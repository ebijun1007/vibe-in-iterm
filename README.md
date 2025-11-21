# Cursor + Vibe Kanban Workspace with `vc`

`vc` is a small helper script for working in **Cursor** while keeping your tasks in **vibe-kanban**. It bootstraps the workspace files/templates you need, starts the kanban board on its default port, launches `ollama serve` for the default OpenCode backend, and primes your local environment for agent work.

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

The command will prepare the workspace for Cursor, start `ollama serve`, and spin up vibe-kanban on its default port when it's not already running.

---

## 🧠 What `vc` does

- Starts `ollama serve` in the background on port `11434` when available (for the default OpenCode backend)
- Starts `npx vibe-kanban` in the background on its default port when not already running (prints the detected URL if available, including when already running)
- Copies templates (`.codex`, `.claude`, `.design`, `todo.md`, `issues.md`, `refactor.json`) into the current directory without overwriting existing files
- Syncs `profiles.json` to the vibe-kanban data directory so your saved boards persist locally
- Adds common local files to `.gitignore` so they stay out of commits
- Touches `todo.md` and opens it in Cursor/VS Code when the `code` CLI is installed

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

Edit `scripts/vc` to adjust defaults such as the vibe-kanban port, the workspace templates directory, or the commands launched for your agents. After editing, rerun `bash setup.sh` to reinstall the updated script into `~/bin`.

---

**Requirements:**
- macOS
- Ollama installed (with models pulled) for the default OpenCode backend
- Node.js + `npx` for running `vibe-kanban`
- Cursor CLI (`code` or `cursor`) if you want `todo.md` to open automatically
- Agent CLIs you plan to run (e.g., `codex`, `claude`)
