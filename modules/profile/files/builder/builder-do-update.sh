#!/bin/bash
set -euxo pipefail

cd "$1"
npm install --cache /tmp/npm-cache-builder
npm update --cache /tmp/npm-cache-builder
npm prune --cache /tmp/npm-cache-builder
node_modules/.bin/grunt --no-color deploy

# Reset to a clean state so that the next deploy will succeed.
git clean -d --force
git reset --hard
