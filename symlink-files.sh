#!/usr/bin/env bash

USER_HOME="/home/arman"  # Explicitly define your home directory
REPO_DIR="$USER_HOME/my-nixos-setup"
HOME_WATCHLIST="$REPO_DIR/home_files_to_watch.txt"
NIXOS_WATCHLIST="$REPO_DIR/nixos_files_to_watch.txt"
INOTIFY_WAIT="$(command -v inotifywait)"

# Check if inotifywait is installed
if [ ! -x "$INOTIFY_WAIT" ]; then
  echo "Error: inotifywait is not installed." >&2
  exit 1
fi

# Symlink files from home
echo "Symlinking home files..."
while IFS= read -r file; do
  src="$file"
  dest="$REPO_DIR/home/${file#$HOME/}"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "Symlinked $src to $dest"
  fi
done < "$HOME_WATCHLIST"

# Symlink files from /etc/nixos
echo "Symlinking NixOS files..."
while IFS= read -r file; do
  src="$file"
  dest="$REPO_DIR/nixos/$(basename "$file")"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "Symlinked $src to $dest"
  fi
done < "$NIXOS_WATCHLIST"


