#!/bin/bash

set -euo pipefail

GIT_DIR="/etc/puppetlabs/code"
cd "$GIT_DIR"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo " -- Fetching Git updates"
git fetch origin -v
PAGER="" git diff "$GIT_BRANCH"..origin/"$GIT_BRANCH"

while true; do
	read -rp " --- Approve the changes (y/n)? " choice
	case "$choice" in
		y|Y)
			break
			;;
		n|N)
			echo "Aborted!"
			exit 1
			;;
	esac
done

ORIGINAL_PUPPETFILE_HASH=$(sha512sum Puppetfile)

echo " -- Merging changes"
git merge --ff-only origin/"$GIT_BRANCH"

NEW_PUPPETFILE_HASH=$(sha512sum Puppetfile)

if [ "$ORIGINAL_PUPPETFILE_HASH" != "$NEW_PUPPETFILE_HASH" ]; then
	echo " -- Updating external modules"
  g10k -puppetfile
fi
