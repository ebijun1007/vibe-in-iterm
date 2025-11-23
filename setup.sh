#!/usr/bin/env bash
set -e

# 0. Ensure Homebrew is available
if ! command -v brew >/dev/null 2>&1; then
  echo "[warn] Homebrew not found. Please install Homebrew first: https://brew.sh/"
  exit 1
fi

# 1. Create scripts directory
mkdir -p scripts

# 2. Install vc command to ~/bin
mkdir -p ~/bin
cp scripts/vc ~/bin/vc
chmod +x ~/bin/vc
echo "[info] Installed vc command to ~/bin/vc"

# 3. Add ~/bin to PATH if not already present
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

# 4. Copy profiles.json to vibe-kanban config directory
VIBE_KANBAN_DIR="$HOME/Library/Application Support/ai.bloop.vibe-kanban"
mkdir -p "$VIBE_KANBAN_DIR"
if [ -f "profiles.json" ]; then
  cp profiles.json "$VIBE_KANBAN_DIR/profiles.json"
  echo "[info] Copied profiles.json to $VIBE_KANBAN_DIR"
else
  echo "[warning] profiles.json not found in current directory"
fi

echo "[done] Setup complete!"
echo ""
echo "Usage:"
echo "  1. Navigate to any directory where you want to work"
echo "  2. Run: vc"
echo "  3. vc will start vibe-kanban and prep workspace files"
