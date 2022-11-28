#!/bin/bash
set -euo pipefail

g10k -puppetfile

for dir in environments/*
do
  ln -s "$(pwd)"/test_data "$dir"/test_data
done
