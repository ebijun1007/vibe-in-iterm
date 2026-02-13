# Coding Agent Workspace with `vc`

`vc` is a small helper script for working with coding agents. It bootstraps your workspace, merges useful commands/skills into your global config, and creates an iTerm layout for agent work.

---

## ⚙️ Setup

### 1. Clone this repository and run the setup script

```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
bash setup.sh
```

This will:
- Add the `vc` function to your `~/.zshrc`

### 2. Reload your shell configuration

```bash
source ~/.zshrc
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

- Copies `.design` into the current project (skips existing files)
- Copies `.claude` into `~/.claude` (skips existing files; except `CLAUDE.md` is overwritten)
- Copies `.codex` into `~/.codex` (skips existing files; except `AGENTS.md` is overwritten)
- Creates an iTerm layout with 3 panes: codex (top), claude (bottom-left), and terminal (bottom-right)

---

## 📁 Files and Directories Modified by Commands

### `setup.sh` Command

When you run `bash setup.sh`, the following files are modified:

| Path | Action | Description |
|------|--------|-------------|
| `~/.zshrc` | Modified | Adds `vc` function |

### `vc` Command

When you run `vc` from any project directory, the following files and directories are created or modified:

| Path | Action | Description |
|------|--------|-------------|
| `$WORKDIR/.design/` | Copied | New files copied from template (existing files preserved) |
| `~/.claude/` | Copied | New files copied from template (existing files preserved) |
| `~/.claude/CLAUDE.md` | Overwritten | Always overwritten from template (if present) |
| `~/.codex/` | Copied | New files copied from template (existing files preserved) |
| `~/.codex/AGENTS.md` | Overwritten | Always overwritten from template (if present) |

> **Note:** `$WORKDIR` refers to the current working directory where you execute the `vc` command.

---

## 📦 Project Structure

```
.
├── vc                # Wrapper that fetches and runs the latest vc-core script
├── scripts/
│   └── vc-core.sh    # Core vc logic
├── setup.sh          # Adds vc function to ~/.zshrc
├── .claude/          # Commands, skills, hooks to merge into ~/.claude
├── .codex/           # Prompts, skills to merge into ~/.codex
├── .design/          # Design files template for projects
└── README.md
```

---

## 🧩 Customization

Edit `scripts/vc-core.sh` to adjust the commands launched for your agents or modify merge behavior.

---

**Requirements:**
- macOS with iTerm.app
- VS Code CLI (`code`) if you want `.design/tasks/` to open automatically
- Agent CLIs you plan to run (e.g., `codex`, `claude`)
