# iTerm 3-Pane Auto Layout with direnv

This repository automatically sets up an **iTerm2 three-pane layout** when you `cd` into the directory, using [`direnv`](https://direnv.net/) and AppleScript.

- **Top left:** runs `codex`
- **Top right:** runs `claude`
- **Bottom:** opens a normal shell in the same directory

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
- Install `direnv` if missing
- Add `eval "$(direnv hook zsh)"` to your shell config
- Create `.envrc` and `scripts/iterm-3pane.scpt`
- Set up automatic iTerm3-pane layout

Then approve the `.envrc`:

```bash
direnv allow
```

---

## 🧠 How It Works

1. `direnv` monitors `.envrc`
2. On entering the directory:
   - Exports `CODEX_HOME="$PWD/.codex"`
   - Calls the AppleScript (`scripts/iterm-3pane.scpt`)
3. The script:
   - Opens a **new iTerm tab**
   - Splits it into three panes:
     - Left top → `codex`
     - Right top → `claude`
     - Bottom → shell in same directory

Infinite recursion is avoided via the `ITERM_LAYOUT_DONE=1` flag.

---

## 📦 Project Structure

```
.
├── .envrc
├── scripts/
│   └── iterm-3pane.scpt
└── setup.sh
```

---

## 🧩 Customization

- To change the commands for the upper panes, edit these lines in `scripts/iterm-3pane.scpt`:
  ```applescript
  write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; codex"
  write text "export ITERM_LAYOUT_DONE=1; cd " & workdir & "; claude"
  ```
  Replace `codex` or `claude` with any command you prefer.

---

## 🔒 Security Notice

Because `.envrc` runs arbitrary shell commands, users must manually approve it:

```bash
direnv allow
```

This is a safeguard to prevent unexpected execution on clone.

---

**Requirements:**
- macOS with iTerm2
- [`direnv`](https://direnv.net/)
- (Optional) Homebrew for automatic installation
