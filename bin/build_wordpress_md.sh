#!/bin/bash

set -euo pipefail

OPTION=${1:-}

newtable="$(php bin/doc_sites_info.php)"

current_content="$(cat doc/wordpress.md)"
template="$(echo "$current_content" | tr '\n' '\r' | sed 's/<!-- .* END -->/__TABLE__/' | tr '\r' '\n')"
new_content="${template//__TABLE__/$newtable}"

if [ "$current_content" != "$new_content" ]; then
  if [ "$OPTION" == "--verify" ]; then
    # signal for "make lint" to fail
    echo "Error: The table in doc/wordpress.md is out-of-date. Run 'make build' to update it." >&2
    exit 1
  else
    echo "$new_content" > doc/wordpress.md
  fi
fi
