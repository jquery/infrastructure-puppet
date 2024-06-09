# Server access

## SSH keys & local workstation security
* Any user accounts and SSH keys must be [managed via Puppet]. Puppet
  will override any local changes.
* We recommend using ed25519 keys (or, alternatively, 4096-bit RSA
  keys).
  * Using a dedicated key for jQuery hosts is recommended but not
    required.
  * If you have an YubiKey (or any other FIDO hardware authenticator),
    modern OpenSSH versions have support [storing SSH keys on them].
* The key you use to log in to jQuery host **must be encrypted** with a
  secure passphrase.
* **Never use SSH agent forwarding** (-A) for the key you use for
  jQuery hosts. Even if [you think you trust the hosts]. This also
  applies to any other other keys you may have loaded in the same agent
  process - if in doubt, assume forwarding an agent anywhere is unsafe.

[managed via Puppet]: ./puppet.md#Managing-user-accounts
[storing SSH keys on them]: https://security.stackexchange.com/questions/240991/what-is-the-sk-ending-for-ssh-key-types
[you think you trust the hosts]: https://matrix.org/blog/2019/05/08/post-mortem-and-remediations-for-apr-11-security-incident/

## SSH host key verification

All servers have SSH host keys signed by the following key:
```
@cert-authority *.ops.jquery.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt01ydjmlHiFKFD3ya6JcQtEPe0WbPj6JnGa/noy4mI jQuery SSH CA v1
```
Save that to `~/.ssh/known_hosts.d/jquery`, and then see the 'SSH
configuration' section below on configuring your SSH client to trust
it.

A [list] of all the host keys is also published, if you want tab
completion.

[list]: https://puppet-04.ops.jquery.net/known_hosts

## SSH configuration

A minimal SSH configuration (`~/.ssh/config` by default) snippet might
look like something like this:

```
Host *.ops.jquery.net
  # Use a file with the CA key (from above), or the full list of all
  # the host keys. Don't trust any other keys.
  UserKnownHostsFile ~/.ssh/known_hosts.d/jquery
  StrictHostKeyChecking yes

  # If your username does not match your local machine:
  User my-username

  # If using a separate SSH key, specify it here:
  IdentityFile ~/.ssh/keys/id_jquery_yk1
```
