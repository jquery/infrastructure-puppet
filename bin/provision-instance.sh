#!/bin/bash
# Script to install Puppet on new instances

set -euo pipefail

INSTANCE=$1
ENVIRONMENT=$2

PUPPET_SERVER=$(python3 -c "import sys, yaml; print(yaml.safe_load(sys.stdin)['profile::puppet::agent::puppet_server'])" < hieradata/environments/"$ENVIRONMENT"/common.yaml)

# https://wiki.debian.org/DebianRepository/UseThirdParty, not needed when Bookworm is out
ssh root@"$INSTANCE" mkdir -p /etc/apt/keyrings

ssh root@"$INSTANCE" curl -o /etc/apt/keyrings/puppet.gpg https://apt.puppet.com/keyring.gpg
ssh root@"$INSTANCE" '. /etc/os-release && echo "deb [signed-by=/etc/apt/keyrings/puppet.gpg] https://apt.puppet.com $VERSION_CODENAME puppet7" > /etc/apt/sources.list.d/puppet.list'
ssh root@"$INSTANCE" apt-get update
ssh root@"$INSTANCE" apt-get upgrade -y
ssh root@"$INSTANCE" apt-get install -y puppet-agent
ssh root@"$INSTANCE" /opt/puppetlabs/bin/puppet config --section agent set server "$PUPPET_SERVER"
ssh root@"$INSTANCE" /opt/puppetlabs/bin/puppet config --section agent set environment "$ENVIRONMENT"
ssh root@"$INSTANCE" /opt/puppetlabs/bin/puppet agent -t
