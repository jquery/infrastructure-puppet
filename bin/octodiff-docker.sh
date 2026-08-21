#!/bin/bash
set -euo pipefail

repo_dir="$(realpath "$(dirname "$0")/..")"

# ruby-dev:
# Required for `gem install octocatalog-diff`
#
# cmake, pkg-config, libgit2-dev:
# Documented requirements of "rugged", a dependency of octocatalog-diff.
#
# libzstd-dev:
# Undocumented requiremenents of "rugged". https://github.com/libgit2/rugged/issues/990
#
# Pin exact octocatalog-diff version to easily apply the patch
# from https://github.com/github/octocatalog-diff/issues/261
script=" \
echo 'Launching debian container...' && \
echo 'Installing packages...' && \
apt-get update -qq && \
DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes apt-get install -y -qq git puppet-agent g10k ruby-dev cmake pkg-config libgit2-dev libzstd-dev > /dev/null && \
echo 'Installing octocatalog-diff...' && \
gem install -q --silent octocatalog-diff -v 2.3.1 && \
cd /infrastructure-puppet && \
patch -u \"\$(gem environment gemdir)/gems/octocatalog-diff-2.3.1/lib/octocatalog-diff/catalog-diff/filter/compilation_dir.rb\" bin/patches/octocatalogdiff_issue261_compilationdir.rb.patch && \
git config --global --add safe.directory /infrastructure-puppet && \
g10k -puppetfile -quiet -cachedir=/infrastructure-puppet/vendor_modules/.g10kcache && \
echo && \
read -p \"PuppetDB Username: \" username && \
read -p \"PuppetDB Password: \" -s password && \
export PUPPETDB_URL=\"https://\$username:\$password@puppet-05.ops.jquery.net:8100/\" && \
echo -e \"\nThe octocatalog-diff command is now ready for use!\n\" && \
/bin/bash;"

# Fix "[g10k] Error: failed to create directory: vendor_modules/X"
mkdir -p "$repo_dir/vendor_modules"

# Fix:
# [g10k] Error: Can't hardlink Forge module files over different devices
# Failed to hardlink /tmp/g10k/forge/X to vendor_modules/X
# Error: link /tmp/g10k/forge/X vendor_modules/X: invalid cross-device link
mkdir -p "$repo_dir/vendor_modules/.g10kcache"

docker run --rm --interactive --tty \
  --mount type=bind,source="$repo_dir",target="/infrastructure-puppet",readonly \
  --mount type=bind,source="$repo_dir/vendor_modules",target="/infrastructure-puppet/vendor_modules" \
  --entrypoint bash debian:trixie-slim -c "$script"
