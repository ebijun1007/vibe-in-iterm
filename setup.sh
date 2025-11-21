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

echo "[done] Setup complete!"
echo ""
echo "Usage:"
echo "  1. Navigate to any directory where you want to work"
echo "  2. Run: vc"
echo "  3. vc will start ollama serve + vibe-kanban in the background and prep workspace files"
