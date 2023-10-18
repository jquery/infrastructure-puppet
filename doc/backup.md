# Backups

We back up some data from our infrastructure using **[Tarsnap][]**.
Tarsnap is an online service that stores incremental encrypted backups.

[Tarsnap]: https://tarsnap.com

* Management: <https://www.tarsnap.com/account.html>
* Access: (Shared)
  * `infrastructure-team@jquery.com`
  * Credentials in the team vault.

Note that the management panel is for billing only, and provides no access to read or delete data.

## Restoring from backups

Backups are end-to-end encrypted and can only be accessed using the private key.

Each host has a unique Tarsnap-specific public-private key pair for encrypting the data and for
write (append back-up data), read (restore backups), and delete (prune old backups) actions.

The private key is stored locally on the original host, with a copy kept on the Puppet server for
recovery purposes. In case both the original host and the Puppet server are lost, one must first
restore the Puppet server's `/srv/git/puppet/private` directory (for which the Tarsnap key is also
stored in the 1Password vault).

See the [Tarsnap documentation][]. You are able to run any of the commands directly as root on the
affected host. If the host is unavailable for whatever reason, a copy of the private key can be
found on the active Puppet server in `/srv/git/puppet/private/files/tarsnap-keys`. You can use
the `--key FILE` argument to specify a decryption key when restoring data for a non-existent
host.

[Tarsnap documentation]: https://www.tarsnap.com/usage.html

## Host management

To add a new host, run the following script as your own user on the Puppet server:

```shell-session
$ jq-tarsnap-keygen FULL-HOSTNAME.ops.jquery.net
```

To delete a host, login to the host in question and run:

```shell-session
$ tarsnap --nuke
```

This will ask for confirmation and then automatically enumerate each backup (`sudo tarsnap --list-archives`) and delete it (`sudo tarsnap -d -f <entry>`).

## Retention policy

Currently we keep all old backups, since it should be reasonably efficient due to the incremental
backup method. This may change when we start backing up some databases.
