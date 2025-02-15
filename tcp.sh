# This file is made for pushing changes to repo quicker.
# tcp.sh stands for (t)rack (c)ommit (p)ush
# [For Linux only] Before running this file, run 'chmod +x tcp.sh' to grant permissions for tcp.sh.

#!/bin/bash

confirm_push() {
    read -p "Do you want to push these changes? (y/n): " choice
    case "$choice" in
        y|Y ) return 0;;
        n|N ) return 1;;
        * ) echo "Invalid choice. Please enter y or n."; return 1;;
    esac
}

# Check if git is installed
if ! which git >/dev/null; then
  echo "Please install Git first or add it to your PATH if installed already."
  exit 1
fi

if [ -z "$1" ]; then
    echo "Please provide a commit message in the first argument."
    exit 1
fi

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [[ "$current_branch" == "master-published" ]]; then
    echo "Error: Cannot push changes to the $current_branch branch."
    exit 1
fi

# echo "Tracking..."
# git add .

echo "Commiting..."
git commit -s -m "$1"

if ! confirm_push; then
    echo "Pushing canceled."
    exit 1
fi

echo "Pushing to $current_branch branch..."
git push -f origin "$current_branch"

if [[ "$current_branch" != "master" ]]; then
    echo "Switching to master branch..."
    git switch master
fi
