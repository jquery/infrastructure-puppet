#!/bin/bash

GIT_DIR="/etc/puppetlabs/code"
GIT_BRANCH=$(git -C "$GIT_DIR" rev-parse --abbrev-ref HEAD)

set -euo pipefail

echo " -- Fetching Git updates"
git -C "$GIT_DIR" fetch origin -v
PAGER="" git -C "$GIT_DIR" diff "$GIT_BRANCH"..origin/"$GIT_BRANCH"

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

echo " -- Merging changes"
git -C "$GIT_DIR" merge --ff-only origin/"$GIT_BRANCH"
