# Server access

## SSH keys & local workstation security

* Any user accounts and SSH keys must be [managed via Puppet]. Puppet
  will override any local changes.
* We recommend using ed25519 keys.
  * Using a dedicated key for jQuery hosts is recommended but not required.
  * If you have an YubiKey (or any other FIDO hardware authenticator),
    modern OpenSSH versions have support [storing SSH keys on them].
* The key you use to log in to jQuery hosts **must be encrypted** with a
  secure passphrase.
* **Never use SSH agent forwarding** (-A) for the key you use for
  jQuery hosts. Even if [you think you trust the hosts]. This also
  applies to any other other keys you may have loaded in the same agent
  process - if in doubt, assume forwarding an agent anywhere is unsafe.

[managed via Puppet]: ./puppet.md#Managing-user-accounts
[storing SSH keys on them]: https://security.stackexchange.com/questions/240991/what-is-the-sk-ending-for-ssh-key-types
[you think you trust the hosts]: https://matrix.org/blog/2019/05/08/post-mortem-and-remediations-for-apr-11-security-incident/

## SSH configuration

You can use the following minimal SSH configuration snippet
(`~/.ssh/config` by default):

```
Host *.ops.jquery.net
  # Only trust the jQuery CA public key. Don't trust any other keys.
  UserKnownHostsFile ~/.ssh/known_hosts.d/jquery
  StrictHostKeyChecking yes

  # If your username does not match your local machine:
  User my-username

  # If using a separate SSH key, specify it here:
  IdentityFile ~/.ssh/keys/id_jquery_yk1
```

### SSH host key verification

All servers have SSH host keys signed by the jQuery SSH CA public key:

```
@cert-authority *.ops.jquery.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt01ydjmlHiFKFD3ya6JcQtEPe0WbPj6JnGa/noy4mI jQuery SSH CA v1
```

Use the below command to download this key, along with fingerprints for
all our servers, which provides tab completion on the `ssh` command.

```sh
curl https://puppet-04.ops.jquery.net/known_hosts | tee ~/.ssh/known_hosts.d/jquery
```

Alternatively, you can copy the above `@cert-authority` line to your
`~/.ssh/known_hosts.d/jquery` file, which would satisfy the strict
host key check, but without tab completion.
