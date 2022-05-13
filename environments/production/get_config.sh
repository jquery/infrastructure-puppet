#!/bin/sh
#
# $1 = environment_name (passed by puppet, ununused)
set -eu

# Ignore local install paths
PATH=/usr/bin:/bin
# Ignore local .gitconfig
export GIT_PAGER=less

script_dir=$(dirname "$0")
repo_dir="${script_dir}/../../.git"
git --git-dir "${repo_dir}" log -1 --pretty='(%h) %cn - %s'
