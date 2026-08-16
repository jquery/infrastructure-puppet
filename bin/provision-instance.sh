#!/usr/bin/env bash
# Script to install Puppet on new instances

set -euo pipefail

INSTANCE=$1
ENVIRONMENT=$2

PUPPET_SERVER=$(cat hieradata/environments/"$ENVIRONMENT"/common.yaml | fgrep puppet_server | cut -d' ' -f2)
VERSION_CODENAME=$(source <(ssh root@"$INSTANCE" cat /etc/os-release); echo "$VERSION_CODENAME")

ssh root@"$INSTANCE" apt-get update
ssh root@"$INSTANCE" apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" upgrade -y
ssh root@"$INSTANCE" apt-get -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" install -y puppet-agent

# temporarily poke firewall rules so this host can be provisioned
INSTANCE_IP4=$(ssh root@"$INSTANCE" facter networking.ip)
INSTANCE_IP6=$(ssh root@"$INSTANCE" facter networking.ip6)
ssh "$PUPPET_SERVER" sudo nft add rule inet filter input tcp dport 8140 ip saddr "$INSTANCE_IP4" ct state new accept
if [[ "$INSTANCE_IP6" != fe80* ]]; then
  ssh "$PUPPET_SERVER" sudo nft add rule inet filter input tcp dport 8140 ip6 saddr "$INSTANCE_IP6" ct state new accept
fi

ssh root@"$INSTANCE" puppet config --section agent set server "$PUPPET_SERVER"
ssh root@"$INSTANCE" puppet config --section agent set environment "$ENVIRONMENT"
ssh root@"$INSTANCE" puppet agent -t || true

REAL_CSR_FINGERPRINT=$(ssh root@"$INSTANCE" openssl req -in /var/lib/puppet/ssl/certificate_requests/"$INSTANCE".pem -outform der | sha256sum | awk '{ print $1 }' | sed 's/\(..\)/\1:/g; s/:$//; s/./\U&/g;')
SERVER_CSR_FINGERPRINT=$(ssh "$PUPPET_SERVER" sudo openssl req -in /etc/puppet/puppetserver/ca/requests/"$INSTANCE".pem -outform der | sha256sum | awk '{ print $1 }' | sed 's/\(..\)/\1:/g; s/:$//; s/./\U&/g;')
if [ "$REAL_CSR_FINGERPRINT" != "$SERVER_CSR_FINGERPRINT" ]; then
  echo "CSR fingerprint does not match!"
  exit 1
fi

ssh "$PUPPET_SERVER" sudo puppetserver ca sign --certname "$INSTANCE"
ssh root@"$INSTANCE" puppet agent -t

# provision permanent firewall rules from data in PuppetDB
ssh "$PUPPET_SERVER" sudo run-puppet-agent
