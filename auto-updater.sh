#!/usr/bin/env bash

USER_HOME="/home/arman"
REPO_DIR="$USER_HOME/my-nixos-setup"
HOME_DIR_REPO="$REPO_DIR/home"
NIXOS_DIR="/etc/nixos"

# Function to list files and directories to monitor in $HOME_DIR_REPO
get_monitored_items() {
  find "$HOME_DIR_REPO" -type f -o -type d | sed "s|$HOME_DIR_REPO|$USER_HOME|g"
}

# Sync changes from home to repo
sync_home_to_repo() {
  echo "Syncing home directory changes..."
  rsync -av --ignore-missing-args --delete --relative --files-from=<(get_monitored_items) "$USER_HOME/" "$REPO_DIR/home/"
  
  # Commit and push changes
  sudo -u arman git -C "$REPO_DIR" add .
  sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync home files $(date)"
  sudo -u arman git -C "$REPO_DIR" push
}

# Sync changes from /etc/nixos to repo
sync_nixos_to_repo() {
  echo "Syncing NixOS directory changes..."
  sudo rsync -av --delete "$NIXOS_DIR/" "$REPO_DIR/nixos/"
  
  # Commit and push changes
  sudo -u arman git -C "$REPO_DIR" add .
  sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync NixOS files $(date)"
  sudo -u arman git -C "$REPO_DIR" push
}

# Start monitoring each file in the $HOME_DIR_REPO explicitly
echo "Starting specific home files monitoring..."
get_monitored_items | while IFS= read -r item; do
    if [ -e "$item" ]; then
        echo "Monitoring: $item"
        inotifywait -m -e modify,close_write,move_self,attrib,delete_self "$item" | while read -r path action file; do
            echo "Detected change in home item: $action $file"
            sync_home_to_repo
        done &
    else
        echo "Skipping missing item: $item"
    fi
done

# Start inotifywait for NixOS files in /etc/nixos
echo "Starting NixOS files monitoring..."
sudo inotifywait -mr -e modify,close_write,move_self,attrib,delete_self "$NIXOS_DIR" | while read -r path action file; do
    echo "Detected change in NixOS directory: $action $file"
    sync_nixos_to_repo
done

wait

