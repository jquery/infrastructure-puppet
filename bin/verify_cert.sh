#!/bin/bash

# SPDX-License-Identifier: MIT
# Copyright 2021 Brian Warner
# Copyright 2023 Timo Tijhof
#
# Very basic utility to run checks on SSL certs prior to deployment.
#
# Usage: ./verify_certs.sh <path to star.jquery.com.pem>
#
#   certname.pem: This is the PEM file created from concatenating the .crt with the .ca-bundle
#   certname.key: This is the private key provided by the issuer
#   certname.ca-bundle: These are the intermediate certs provided by the issuer
#

if [ "$#" -ne 1 ]; then
  echo "Usage: ./verify_certs.sh <path to star.jquery.com.pem>"
  exit
fi

pemfilename="$1"
keyfilename="${1%.pem}.key"
cabundlefilename="${1%.pem}_bundle.pem"
if [ ! -f "$pemfilename" ]; then
  echo -e "Error: Could not find $pemfilename"
  exit 1
fi
if [ ! -f "$keyfilename" ]; then
  echo -e "Error: Could not find $keyfilename"
  exit 1
fi
if [ ! -f "$cabundlefilename" ]; then
  echo -e "Error: Could not find $cabundlefilename"
  exit 1
fi

bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n${bold}Dates the cert is valid (expect today to be within this range):${normal}"
openssl x509 -noout -dates -in "$pemfilename"

echo -e "\n${bold}Verifying validity of the certificate chain (expect \"OK\"):${normal}"
openssl verify -CAfile "$cabundlefilename" "$pemfilename"

echo -e "\n${bold}Verify the public keys match (expect \"Keys match\"):${normal}"
pemkey=`openssl x509 -noout -pubkey -in "$pemfilename"`
pubkey=`openssl ec -pubout -in "$keyfilename" 2>/dev/null`
keydiff=`diff <(echo $pemkey) <(echo $pubkey)`

if [ ${#keydiff} -eq 0 ]; then
  echo -e "Keys match"
else
  echo -e "\033[0;31mKeys do not match, check you have the correct .key and .pem files.\033[0;37m"
fi

echo -e "\n${bold}Verify the PEM file is in the right order (expect issuer to match next subject)${normal}"
openssl crl2pkcs7 -nocrl -certfile "$pemfilename" | openssl pkcs7 -print_certs -noout

