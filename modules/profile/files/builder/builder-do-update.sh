#!/bin/bash
set -euxo pipefail

cleanup() {
  # Reset to a clean state so that the next deploy (and its git update) will succeed.
  git clean -d --force
  git reset --hard
}
trap cleanup EXIT

export NODE_ENV=production

cd "$1"
npm install
npm update
npm prune

GRUNT="$(npm bin)/grunt"
SERVERS="$(cat /etc/builder-wordpress-hosts)"

for SERVER in $SERVERS
do
  WP_HOST="$SERVER" "$GRUNT" deploy
done
