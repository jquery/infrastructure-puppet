#!/bin/bash

# SPDX-License-Identifier: MIT
# Copyright 2022 Timo Tijhof
#
# Save the decrypted form of a private key provided by the issuer.
# This will prompt for an encryption password.
#

set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: ./decrypt_cert_key.sh encrypted_input.key plaintext_output.key"
  exit
fi

keyfilesrc=$1
keyfiledest=$2

openssl pkcs8 -in "$keyfilesrc" -out "$keyfiledest"
