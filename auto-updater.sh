#!/usr/bin/env bash
# Paths to the text files
USER_HOME="/home/arman"  # Explicitly define your home directory
REPO_DIR="$USER_HOME/my-nixos-setup"

HOME_FILES_LIST="$REPO_DIR/home_files_to_watch.txt"
NIXOS_FILES_LIST="$REPO_DIR/nixos_files_to_watch.txt"

# Start inotifywait to monitor home files
if [[ -f "$HOME_FILES_LIST" ]]; then
    inotifywait -mr -e modify,create,delete,move --fromfile "$HOME_FILES_LIST" | while read event
    do
        echo "Detected change in home: $event"
        
        # Sync the changes from system to the repo
        rsync -av --files-from="$HOME_FILES_LIST" "$USER_HOME/" "$REPO_DIR/home/"

        # Commit and push changes to the repo as your user (not root)
        sudo -u arman git -C "$REPO_DIR" add .
        sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync home files $(date)"
        sudo -u arman git -C "$REPO_DIR" push
    done &
fi

# Start inotifywait to monitor all files in /etc/nixos
sudo inotifywait -mr -e modify,create,delete,move /etc/nixos/ | while read event
do
    echo "Detected change in NixOS: $event"

    # Sync the changes from /etc/nixos to the repo
    sudo rsync -av /etc/nixos/ "$REPO_DIR/nixos/"

    # Commit and push changes to the repo as your user (not root)
    sudo -u arman git -C "$REPO_DIR" add .
    sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync NixOS files $(date)"
    sudo -u arman git -C "$REPO_DIR" push
done

wait

