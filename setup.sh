#!/usr/bin/env bash
set -e

# Helper function to ensure markdown files exist as real files (not symlinks)
ensure_markdown_file() {
  local file="$1"
  if [ -L "$file" ]; then
    rm "$file"
  fi
  touch "$file"
}

# 1. Create scripts directory
mkdir -p scripts

# 2. Create markdown files
ensure_markdown_file "AGENTS.md"
ensure_markdown_file "CLAUDE.md"
ensure_markdown_file "todo.md"
echo "[info] Ensured AGENTS.md, CLAUDE.md, and todo.md exist"

# 3. Install vc command to ~/bin
mkdir -p ~/bin
cp scripts/vc ~/bin/vc
chmod +x ~/bin/vc
echo "[info] Installed vc command to ~/bin/vc"

# 4. Add ~/bin to PATH if not already present
# Detect shell from $SHELL environment variable
SHELL_RC=""
case "$SHELL" in
  */zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  */bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  *)
    echo "[warning] Unknown shell: $SHELL"
    echo "[info] Please manually add this line to your shell config:"
    echo '  export PATH="$HOME/bin:$PATH"'
    ;;
esac

if [ -n "$SHELL_RC" ]; then
  if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
    echo '[info] Adding ~/bin to PATH in '"$SHELL_RC"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
    echo "[info] Please run: source $SHELL_RC"
  else
    echo "[info] PATH already configured in $SHELL_RC"
  fi
fi

echo "[done] Setup complete!"
echo ""
echo "Usage:"
echo "  1. Navigate to any directory where you want to work"
echo "  2. Run: vc"
echo "  3. iTerm will create a new tab with 4 panes (todo viewer, codex, claude, shell)"
