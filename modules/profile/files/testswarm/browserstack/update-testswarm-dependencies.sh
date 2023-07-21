#!/bin/bash
set -euxo pipefail

NODE_ENV=production exec /usr/bin/npm install --prefix /srv/testswarm-browserstack --cache /tmp/npm-testswarm-browserstack
