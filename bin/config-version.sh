#!/bin/bash
# $1 = environment_name (passed by puppet, ununused)
set -euo pipefail

# Ignore local install paths
PATH=/usr/bin:/bin
# Ignore local .gitconfig
export GIT_PAGER=less

script_dir=$(dirname "$0")

for repo_dir in "${script_dir}/../.git" /tmp/g10k/environments/jquery-puppet.git/
do
  if [ -d "$repo_dir" ]; then
    git --git-dir "${repo_dir}" log -1 --pretty='(%h) %cn - %s'
    exit 0
  fi
done

echo 'unknown'
