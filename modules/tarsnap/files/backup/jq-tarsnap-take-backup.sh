#!/bin/sh

NAME="$1"
shift

# https://www.tarsnap.com/usage.html
exec tarsnap -c -f "$NAME-$(date +%Y-%m-%d_%H-%M-%S)" "$@"
