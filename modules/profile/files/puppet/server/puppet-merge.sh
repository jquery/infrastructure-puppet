#!/bin/bash

set -euo pipefail

G10K_CONFIG_FILE=/etc/puppet/g10k.yaml
if [ ! -f "$G10K_CONFIG_FILE" ]; then
  G10K_CONFIG_FILE=/etc/puppetlabs/g10k.yaml
fi

sudo -u gitpuppet g10k -config "$G10K_CONFIG_FILE"
