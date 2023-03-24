#!/bin/sh
cd "$1"
npm install --cache /tmp/npm-cache-builder
npm update --cache /tmp/npm-cache-builder
npm prune --cache /tmp/npm-cache-builder
node_modules/.bin/grunt --no-color deploy
