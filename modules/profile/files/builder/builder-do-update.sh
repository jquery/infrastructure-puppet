#!/bin/bash
set -euxo pipefail

export NODE_ENV=production

cd "$1"
npm install
npm update
npm prune
node_modules/.bin/grunt --no-color deploy

# Reset to a clean state so that the next deploy will succeed.
git clean -d --force
git reset --hard
