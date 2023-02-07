#!/bin/sh

NAME="$1"
shift

exec tarsnap -c -f "$NAME-$(date +%Y-%m-%d_%H-%M-%S)" "$@"
