# Backups

We back up some data from our infrastructure using [Tarsnap][].

[Tarsnap]: https://tarsnap.com

## Restoring from backups

See the [Tarsnap documentation][]. You are able to run any of the commands directly as root on the
affected host. If the host is unavailable for whatever reason, the keys are also backed up on the
active Puppet master in `/srv/git/puppet/private/files/tarsnap-keys`. You can use the `--key FILE`
argument to specify the key to use if you need to restore data for a non-existent host.

[Tarsnap documentation]: https://www.tarsnap.com/usage.html

If the Puppet host itself is gone, its Tarsnap key is included in the 1password vault. Then you can
restore the private repository from backups to access keys for other hosts.

## Host management

To add a new host, run the following script as your own user on the current Puppet host:
```shell-session
$ jq-tarsnap-keygen FULL-HOSTNAME.ops.jquery.net
```

To delete a host, use this script:
TODO

## Retention policy

Currently we keep all old backups, since it should be reasonably efficient due to the incremental
backup method. This may change when we start backing up some databases.
