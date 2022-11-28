#!/bin/bash
# $1 = environment_name (passed by puppet, ununused)
set -euo pipefail

# Ignore local install paths
PATH=/usr/bin:/bin
# Ignore local .gitconfig
export GIT_PAGER=less

script_dir=$(dirname "$0")
repo_dir="${script_dir}/../.git"

if [ -d "$repo_dir" ]; then
  git --git-dir "${repo_dir}" log -1 --pretty='(%h) %cn - %s'
else
  echo 'unknown'
fi
