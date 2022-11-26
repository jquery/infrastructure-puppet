#!/bin/sh
# Set a constant file modification timestamp for all CDN assets
#
# Git does not store modified file timestamps, which means the on-disk mtime
# for most files is set to the time of the Git clone. While Apache has an
# option to configure how E-Tag is computed (e.g. based on content only), Nginx
# is always based on file mtime and file size.
#
# As a workaround, set a fixed timestamp for all CDN files. This is okay as
# we don't actually utilized Last-Modified or E-Tag for propagating changes,
# we only use them as a way to re-assure browsers that files haven't changed
# and thus reduce bandwidth from needless re-transfers. Given our maximum
# Cache-Control "max-age", it is already the case that a changed file will not
# be seen by the CDN unless we purge it via the CDN API, and not seen by previous
# browser clients until they clear their own caches.
find /srv/codeorigin/cdn/ -type f -print0 | TZ=UTC xargs -0 -P 4 -n 50 touch --date='1991-10-18 12:00:00'
