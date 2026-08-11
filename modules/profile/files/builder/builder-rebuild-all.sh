#!/bin/bash
set -euo pipefail

echo "== List sites and quietly git pull..."

for site in /srv/builder/*; do echo "* $site" && sudo -u builder git -C "$site" pull --quiet; done

BUILD_BATCHSIZE=4
echo
echo "== Rebuild all sites... ($BUILD_BATCHSIZE concurrent jobs)"

tmpdir="$(mktemp -d "rebuildall.XXXXXXX")"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

sites=(/srv/builder/*)
start_index=0
while (( start_index < ${#sites[@]} )); do
  end_index=$(( start_index + BUILD_BATCHSIZE ))
  if (( end_index > ${#sites[@]} )); then
    end_index=${#sites[@]}
  fi

  # Start in background and capture stdout+stderr into a tmp file
  batch_sites=( "${sites[@]:start_index:end_index-start_index}" )
  pids=()
  pid_to_site=()
  pid_to_tmp=()
  for site in "${batch_sites[@]}"; do
    tmp="$tmpdir/$(basename "$site").out"
    sudo -u builder builder-do-update "$site" >"$tmp" 2>&1 &
    pid=$!
    pids+=( "$pid" )
    pid_to_site["$pid"]="$site"
    pid_to_tmp["$pid"]="$tmp"
  done

  # Wait for batch to finish
  for pid in "${pids[@]}"; do
    site="${pid_to_site[$pid]}"
    if wait "$pid"; then
      echo "=== $site: Done"
    else
      echo "=== $site: FAILED"
      cat "${pid_to_tmp[$pid]}"
      echo
    fi
  done

  start_index=$end_index
done

echo "== All done."
