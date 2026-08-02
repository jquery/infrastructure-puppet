#!/usr/bin/env bash

set -euo pipefail

PUPPET_SERVER=$(cat hieradata/environments/production/common.yaml | fgrep puppet_server | cut -d' ' -f2)

if [ -z "$PUPPET_SERVER" ]; then
  echo "Could not find puppet_server in /hieradata/environments/production/common.yaml" 1>&2
  exit 1
fi

usage() {
  cat <<EOF
restore a Tarsnap archive from an old node to a destination node

USAGE

  ./restore-tarsnap.sh <action> <old_fqdn> [<archive_name>] [<dest_fqdn>]

DESCRIPTION

This will connect to the puppetserver to obtain a read-only Tarsnap key on
behalf of the old node. Then, it connects to the destination node to restore
a chosen archive under /root/restored_from_tarsnap/.

The destination node must be online and provisioned (it should at least accept
your SSH key as root, and have tarsnap installed).

The old node does not have to be online.

EXAMPLES

List the most recent 30 archives (this may take several minutes).

  ./restore-tarsnap.sh list old.example.net

If you need to access an older archive, ssh to the puppetserver and run the
following instead to produce a full list. Note that the list is streamed out
without any order due to the metadata being encrypted. Pipe to 'sort' to trade
streaming for order.

  you@puppetserver$ sudo tarsnap --list-archives --key /srv/git/puppet/private/files/tarsnap-keys/<OLD_FQDN>.key

Restore a specific archive under dest.example.net:/root/restored_from_tarsnap

  ./restore-tarsnap.sh restore old.example.net wordpress-2021-04-01_09-38-01 dest.example.net

EOF
}

fatalerr() {
  printf %s "$1" 1>&2
  exit 1
}

if [ "$#" -lt 2 ]; then
  usage 1>&2
  exit 1
fi
if [ "$#" -gt 4 ]; then
  fatalerr "Too many arguments"
fi

ACTION=$1
OLD_INSTANCE=$2
ARCHIVE_NAME=${3:-}
DEST_INSTANCE=${4:-}

OLD_MASTER_KEY="/srv/git/puppet/private/files/tarsnap-keys/$OLD_INSTANCE.key"
OLD_RO_KEY="/srv/git/puppet/private/files/tarsnap-keys/$OLD_INSTANCE.tmp_readonly.key"

if [ "$ACTION" == "list" ]; then
  if ssh "$PUPPET_SERVER" "sudo test ! -e $(printf %q "$OLD_MASTER_KEY")"; then
    fatalerr "Could not find $OLD_KEYFILE on $PUPPET_SERVER"
  fi

  echo "... retrieve list of archives (this may take a few minutes)"
  archives=$(ssh "$PUPPET_SERVER" "sudo tarsnap --list-archives --keyfile $(printf %q "$OLD_MASTER_KEY")")

  echo "... found $(printf '%s' "$archives" | wc -l) archives"

  echo "The 30 more recent archives from $OLD_INSTANCE:"
  # Using "|| true" to prevent "head" causing error 141 (SIGPIPE)
  archives_desc_last=$(printf '%s' "$archives" | sed -E 's/(\-[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9-]+$)/ \1/' | sed '/^[[:space:]]*$/d' | sort -r -t ' ' -k 2 -k 1 | tr -d ' ' | head -n30 || true)
  printf "%s\n" "$archives_desc_last"

elif [ "$ACTION" == "restore" ]; then
  if [ -z "$ARCHIVE_NAME" ]; then
    fatalerr "Missing archive name argument"
  fi
  if [ -z "$DEST_INSTANCE" ]; then
    fatalerr "Missing destination argument"
  fi

  DEST_OLD_RO_KEY="/root/$(basename "$OLD_RO_KEY")"
  DEST_EXTRACT_PARENT="/root/restored_from_tarsnap"
  DEST_EXTRACT_DIR="$DEST_EXTRACT_PARENT/$OLD_INSTANCE--$ARCHIVE_NAME"

  echo "... derive read-only key"
  if ! ssh "$PUPPET_SERVER" "sudo test -f $(printf %q "$OLD_RO_KEY")"; then
    if ! ssh "$PUPPET_SERVER" "sudo tarsnap-keymgmt --outkeyfile $(printf %q "$OLD_RO_KEY") -r $(printf %q "$OLD_MASTER_KEY")"; then
      fatalerr "Failed to derive read-only key"
    fi
  fi

  echo "... transfer read-only key to $DEST_INSTANCE"
  if ! scp root@"$PUPPET_SERVER":"$OLD_RO_KEY" root@"$DEST_INSTANCE":"$DEST_OLD_RO_KEY"; then
    fatalerr "Failed to transfer read-only key"
  fi

  echo "... downloading archive and extracting to $DEST_INSTANCE:$DEST_EXTRACT_PARENT"
  ssh root@"$DEST_INSTANCE" mkdir -p "$DEST_EXTRACT_PARENT"
  # This intentionally fails if it exists.
  # Let operator move or remove any ambiguous data out of the way first.
  ssh root@"$DEST_INSTANCE" mkdir "$DEST_EXTRACT_DIR"
  ssh root@"$DEST_INSTANCE" tarsnap -x -f "$ARCHIVE_NAME" --keyfile "$DEST_OLD_RO_KEY" -C "$DEST_EXTRACT_DIR"  --progress-bytes 1048576

  echo "... clean up read-only key"
  ssh root@"$DEST_INSTANCE" "rm $(printf %q "$DEST_OLD_RO_KEY")"
  ssh "$PUPPET_SERVER" "sudo rm $(printf %q "$OLD_RO_KEY")"

  echo "Done!"
else
  fatalerr "Unknown action argument: $ACTION"
fi
