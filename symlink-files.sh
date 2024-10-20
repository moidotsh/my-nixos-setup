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

# Copy files from home instead of symlinking
echo "Copying home files..."
while IFS= read -r file; do
  src="$file"
  dest="$REPO_DIR/home/${file#$USER_HOME/}"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp -f "$src" "$dest"  # Copy the actual file instead of creating symlink
    echo "Copied $src to $dest"
  fi
done < "$HOME_WATCHLIST"

# Copy files from /etc/nixos instead of symlinking
echo "Copying NixOS files..."
while IFS= read -r file; do
  src="$file"
  dest="$REPO_DIR/nixos/$(basename "$file")"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp -f "$src" "$dest"  # Copy the actual file instead of creating symlink
    echo "Copied $src to $dest"
  fi
done < "$NIXOS_WATCHLIST"

# Commit and push the changes to the Git repository
echo "Pushing changes to Git..."
cd "$REPO_DIR" || exit 1
sudo -u arman git add .
sudo -u arman git commit -m "Updated with latest files"
sudo -u arman git push

