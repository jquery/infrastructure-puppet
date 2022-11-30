#!/bin/bash

set -euo pipefail

if [ "$(whoami)" != "gitpuppet" ]
then
  exec sudo -u gitpuppet puppet-merge
  exit 0
fi

g10k -config /etc/puppetlabs/g10k.yaml
