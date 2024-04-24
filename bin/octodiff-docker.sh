#!/bin/bash
set -euo pipefail

repo_dir="$(realpath "$(dirname "$0")/..")"

script=" \
echo 'Launching debian container...' && \
echo 'Installing packages...' && \
apt-get update -qq && \
DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes apt-get install -y -qq git octocatalog-diff puppet-agent puppet-module-puppetlabs-sshkeys-core g10k > /dev/null && \
cd /infrastructure-puppet && \
patch -u /usr/lib/ruby/vendor_ruby/octocatalog-diff/catalog-diff/filter/compilation_dir.rb bin/patches/octocatalogdiff_issue261_compilationdir.rb.patch && \
git config --global --add safe.directory /infrastructure-puppet && \
g10k -puppetfile -quiet -cachedir=/infrastructure-puppet/vendor_modules/.g10kcache && \
echo && \
read -p \"PuppetDB Username: \" username && \
read -p \"PuppetDB Password: \" -s password && \
export PUPPETDB_URL=\"https://\$username:\$password@puppet-03.ops.jquery.net:8100/\" && \
echo -e \"\nThe octocatalog-diff command is now ready for use!\n\" && \
/bin/bash;"

# [g10k] Error: failed to create directory: vendor_modules/X
mkdir -p "$repo_dir/vendor_modules"
# [g10k] Error: Can't hardlink Forge module files over different devices
# Failed to hardlink /tmp/g10k/forge/X to vendor_modules/X
# Error: link /tmp/g10k/forge/X vendor_modules/X: invalid cross-device link

mkdir -p "$repo_dir/vendor_modules/.g10kcache"

docker run --rm --interactive --tty \
  --mount type=bind,source="$repo_dir",target="/infrastructure-puppet",readonly \
  --mount type=bind,source="$repo_dir/vendor_modules",target="/infrastructure-puppet/vendor_modules" \
  --entrypoint bash debian:bookworm-slim -c "$script"
