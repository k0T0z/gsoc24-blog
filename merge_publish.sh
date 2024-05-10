# `master` branch is for uploading changes frequently to the repo. However `master-published` branch is where
# the actual site is hosted. So, in order to publish the changes, we need to merge `master` branch
# to `master-ready` branch. This is where `merge_publish.sh` comes in.
# [For Linux only] Before running this file, run 'chmod +x merge_publish.sh' to grant permissions for merge_publish.sh.

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

chmod +x tcp.sh

echo "Commiting and pushing to master branch first..."
./tcp.sh "Merge master branch into master-ready branch"

echo "Switching to master-ready branch if not already..."
git switch master-ready

echo "Merging master branch into master-ready branch..."
git merge master

if ! confirm_push; then
    echo "Pushing canceled."
    echo "Switching back to master branch..."
    git switch master
    exit 1
fi

echo "Pushing to master-ready..."
git push -f origin master-ready

echo "Switching back to master branch..."
git switch master
