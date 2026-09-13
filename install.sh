#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
VAULT=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [--vault /path/to/obsidian-vault]

Symlinks Ghostty, AeroSpace, zsh, and JankyBorders configs into place.
If you pass --vault, the Obsidian theme, snippet, and plugin bits
are copied into that vault's .obsidian folder.
Vorssaint settings are a plist in vorssaint/. Import that from
Vorssaint Settings > Advanced. The script will not do it for you.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault)
      VAULT="${2:-}"
      if [[ -z "$VAULT" ]]; then
        echo "Missing path after --vault" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

link() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" ]]; then
      rm "$dest"
    else
      mv "$dest" "${dest}.bak"
      echo "Moved existing $dest to ${dest}.bak"
    fi
  fi
  ln -sfn "$src" "$dest"
  echo "Linked $dest"
}

clone_plugin() {
  local name="$1"
  local url="$2"
  local dest="$HOME/.oh-my-zsh/custom/plugins/$name"
  if [[ -d "$dest" ]]; then
    return
  fi
  git clone --depth=1 "$url" "$dest"
}

link "$REPO/aerospace.toml" "$HOME/.aerospace.toml"
link "$REPO/ghostty/config" "$HOME/.config/ghostty/config"
link "$REPO/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
link "$REPO/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
link "$REPO/zsh/zshrc" "$HOME/.zshrc"
link "$REPO/zsh/zshenv" "$HOME/.zshenv"
link "$REPO/zsh/zprofile" "$HOME/.zprofile"
link "$REPO/borders/bordersrc" "$HOME/.config/borders/bordersrc"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab
  clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
  clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
else
  echo "Oh My Zsh is not installed. Skipping plugin clones."
  echo "Install it from https://ohmyz.sh then run this script again."
fi

if [[ -n "$VAULT" ]]; then
  if [[ ! -d "$VAULT" ]]; then
    echo "Vault path does not exist: $VAULT" >&2
    exit 1
  fi
  mkdir -p "$VAULT/.obsidian"
  rsync -a "$REPO/obsidian/" "$VAULT/.obsidian/"
  echo "Copied Obsidian config into $VAULT/.obsidian"
fi

echo "Done. Open Ghostty and reload AeroSpace if they were already running."
