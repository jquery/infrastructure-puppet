#!/bin/bash
# Manages Tarsnap keys for jQuery machines

set -euo pipefail
. /etc/jq-tarsnap-keygen.sh

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
git -C "$TARSNAP_KEYS_BASE_PATH" commit -m "add Tarsnap keys for $INSTANCE"
