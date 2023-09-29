#!/bin/bash
# Removes an instance

set -euo pipefail
. /etc/jq-tarsnap-keygen.sh

INSTANCE="$1"

TARSNAP_KEYFILE="$TARSNAP_KEYS_BASE_PATH/$INSTANCE.key"

echo "=== Cleaning up $INSTANCE"

if [ -f "$TARSNAP_KEYFILE" ]; then
  echo "Cleaning up old Tarsnap backups and key file"
  if ! git -C "$TARSNAP_KEYS_BASE_PATH" diff-index --quiet HEAD --; then
    echo "The private git directory has uncommitted changes, please fix that before running this script."
    exit 1
  fi

  tarsnap --keyfile "$TARSNAP_KEYFILE" --nuke

  git -C "$TARSNAP_KEYS_BASE_PATH" rm "$TARSNAP_KEYFILE"
  git -C "$TARSNAP_KEYS_BASE_PATH" commit -m "remove Tarsnap keys for $INSTANCE"
fi

echo "Removing from Puppet"

sudo puppet node deactivate "$INSTANCE"
sudo puppet node clean "$INSTANCE"

echo "=== All done."
