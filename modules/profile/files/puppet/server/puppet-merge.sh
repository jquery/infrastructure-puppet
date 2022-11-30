#!/bin/bash

set -euo pipefail

if [ "$(whoami)" != "gitpuppet" ]
then
  exec sudo -u gitpuppet puppet-merge
  exit 0
fi

g10k -config /etc/puppetlabs/g10k.yaml

GIT_DIR="/srv/git/puppet/public"
cd "$GIT_DIR"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo " -- Fetching Git updates"
git fetch origin -v

ORIGINAL_PUPPETFILE_HASH=$(sha512sum Puppetfile)

echo " -- Merging changes"
git merge --ff-only origin/"$GIT_BRANCH"

NEW_PUPPETFILE_HASH=$(sha512sum Puppetfile)

if [ "$ORIGINAL_PUPPETFILE_HASH" != "$NEW_PUPPETFILE_HASH" ]; then
    echo " -- Updating external modules"
    g10k -puppetfile
fi
