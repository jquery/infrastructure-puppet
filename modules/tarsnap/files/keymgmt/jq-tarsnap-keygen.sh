#!/bin/bash
# Manages Tarsnap keys for jQuery machines

set -euo pipefail
. /etc/jq-tarsnap-keymgmt-config.sh

INSTANCE=$1

KEYFILE="$TARSNAP_KEYS_BASE_PATH/$INSTANCE.key"

if ! git -C "$TARSNAP_KEYS_BASE_PATH" diff-index --quiet HEAD --; then
  echo "The private git directory has uncommitted changes, please fix that before running this script."
  exit 1
fi

if [ -f "$KEYFILE" ]; then
  echo "Key file $KEYFILE already exists!"
  exit 1
fi

tarsnap-keygen --keyfile "$KEYFILE" --user "$TARSNAP_ACCOUNT_EMAIL" --machine "$INSTANCE"
chmod 660 "$KEYFILE"
git -C "$TARSNAP_KEYS_BASE_PATH" add "$KEYFILE"

# Git already infers a default author email (username@hostname), extend this author name as well
# Avoid "fatal: empty ident name (for <example@puppet-00.test>) not allowed"
if [ "$(id -un)" != "root" ]; then
  if ! git var GIT_AUTHOR_IDENT; then
    export GIT_AUTHOR_NAME="$(id -un)"
    export GIT_COMMITTER_NAME="$(id -un)"
  fi
fi

git -C "$TARSNAP_KEYS_BASE_PATH" commit -m "add Tarsnap keys for $INSTANCE"
