#!/usr/bin/python3
import argparse
import sys
from pathlib import Path

from cryptography import x509
from cryptography.x509.oid import ExtensionOID


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=Path)
    parser.add_argument("domain", nargs="+")
    args = parser.parse_args()

    with args.file.open("rb") as f:
        cert = x509.load_pem_x509_certificate(f.read())

    san_ext = cert.extensions.get_extension_for_oid(
        ExtensionOID.SUBJECT_ALTERNATIVE_NAME
    )
    real_dns_names = set(san_ext.value.get_values_for_type(x509.DNSName))

    if real_dns_names != set(args.domain):
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
