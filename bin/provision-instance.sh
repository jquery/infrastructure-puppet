#!/usr/bin/env bash
# Script to install Puppet on new instances

set -euo pipefail

INSTANCE=$1
ENVIRONMENT=$2

PUPPET_SERVER=$(python3 -c "import sys, yaml; print(yaml.safe_load(sys.stdin)['profile::puppet::agent::puppet_server'])" < hieradata/environments/"$ENVIRONMENT"/common.yaml)
VERSION_CODENAME=$(source <(ssh root@"$INSTANCE" cat /etc/os-release); echo "$VERSION_CODENAME")

PUPPET="puppet"
SSL_PATH="/var/lib/puppet/ssl"

if [ "$VERSION_CODENAME" == "bullseye" ]; then
  PUPPET="/opt/puppetlabs/bin/puppet"
  SSL_PATH="/etc/puppetlabs/puppet/ssl"

  # https://wiki.debian.org/DebianRepository/UseThirdParty, not needed when Bookworm is out
  ssh root@"$INSTANCE" mkdir -p /etc/apt/keyrings

  ssh root@"$INSTANCE" curl -o /etc/apt/keyrings/puppet.gpg https://apt.puppet.com/keyring.gpg
  ssh root@"$INSTANCE" '. /etc/os-release && echo "deb [signed-by=/etc/apt/keyrings/puppet.gpg] https://apt.puppet.com $VERSION_CODENAME puppet7" > /etc/apt/sources.list.d/puppet.list'
fi

ssh root@"$INSTANCE" apt-get update
ssh root@"$INSTANCE" apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" upgrade -y
ssh root@"$INSTANCE" apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install -y puppet-agent
ssh root@"$INSTANCE" "$PUPPET" config --section agent set server "$PUPPET_SERVER"
ssh root@"$INSTANCE" "$PUPPET" config --section agent set environment "$ENVIRONMENT"
ssh root@"$INSTANCE" "$PUPPET" agent -t || true

REAL_CSR_FINGERPRINT=$(ssh root@"$INSTANCE" openssl req -in "$SSL_PATH"/certificate_requests/"$INSTANCE".pem -outform der | sha256sum | awk '{ print $1 }' | sed 's/\(..\)/\1:/g; s/:$//; s/./\U&/g;')
SERVER_CSR_FINGERPRINT=$(ssh "$PUPPET_SERVER" sudo openssl req -in /etc/puppet/puppetserver/ca/requests/"$INSTANCE".pem -outform der | sha256sum | awk '{ print $1 }' | sed 's/\(..\)/\1:/g; s/:$//; s/./\U&/g;')
if [ "$REAL_CSR_FINGERPRINT" != "$SERVER_CSR_FINGERPRINT" ]; then
  echo "CSR fingerprint does not match!"
  exit 1
fi

ssh "$PUPPET_SERVER" sudo puppetserver ca sign --certname "$INSTANCE"
ssh root@"$INSTANCE" "$PUPPET" agent -t
