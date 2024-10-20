#!/usr/bin/env bash

USER_HOME="/home/arman"
REPO_DIR="$USER_HOME/my-nixos-setup"

# Function to dynamically list the files in the repo_dir/home folder and save them to a temporary file
get_home_files() {
    find "$REPO_DIR/home" -type f | while read file; do
        # Convert paths and only list files that exist
        real_file_path="${file/$REPO_DIR\/home/$USER_HOME}"
        if [[ -e "$real_file_path" ]]; then
            echo "$real_file_path"
        else
            echo "Skipping non-existent file: $real_file_path" >&2
        fi
    done
}

# Start inotifywait to monitor dynamically generated list of home files
inotifywait -mr -e modify,create,delete,move --fromfile <(get_home_files) | while read event; do
    echo "Detected change in home: $event"

    # Sync the changes from system to the repo
    rsync -av "$USER_HOME/" "$REPO_DIR/home/" --delete

    # Commit and push changes to the repo as your user (not root)
    sudo -u arman git -C "$REPO_DIR" add .
    sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync home files $(date)"
    sudo -u arman git -C "$REPO_DIR" push
done &

# Start inotifywait to monitor all files in /etc/nixos
sudo inotifywait -mr -e modify,create,delete,move /etc/nixos/ | while read event; do
    echo "Detected change in NixOS: $event"

    # Sync the changes from /etc/nixos to the repo
    sudo rsync -av /etc/nixos/ "$REPO_DIR/nixos/" --delete

    # Commit and push changes to the repo as your user (not root)
    sudo -u arman git -C "$REPO_DIR" add .
    sudo -u arman git -C "$REPO_DIR" commit -m "Auto-sync NixOS files $(date)"
    sudo -u arman git -C "$REPO_DIR" push
done

wait

