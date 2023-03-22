# Puppet usage

## Applying changes

All nodes run Puppet every 30 minutes or so, so just pushing
commits to the correct branch is usually all that's needed.

However, if you need to manually run Puppet, there is a wrapper script
called `run-puppet-agent` that should be used instead of directly
executing `puppet agent -tv`.

## Provisioning new nodes

Add the instance to `site.pp`, `puppet-merge` that commit and use the
`bin/provision-instance.sh` script on your local machine:
```bash
$ bin/provision-instance.sh codeorigin-02.stage.ops.jquery.net staging
```

## Conventions

This section documents some conventions that are in place on this
repository to keep it maintainable as it grows and gets older.

### Modules

The code is organized as modules, profiles and roles like this:
* **Modules** maintain a single piece of software or configuration. For
  example, there might be a module to maintain nginx or systemd, and
  there might be a module to maintain the user accounts for admins.
* **Profiles** maintain a single piece of functionality, for example
  "a web server for the jQuery CDN backend" or "a PostgreSQL database
  for PuppetDB". Profiles use modules and optionally inherit other
  profiles (when that profile is a strict requirement).
* **Roles** apply a list of profiles to a node. Each node definition
  in `site.pp` is only allowed to contain exactly one role definition
  using the `role('name')` function.

In general we avoid using third-party dependencies. There are a few
exceptions, and those are managed in `Puppetfile` using [g10k].

[g10k]: https://github.com/xorpaul/g10k

### Configuration

Configuration that might need to changed often, must stay private or
be different in different parts of the infrastructure should be managed
by the Hiera system.

The only permitted way to look up Hiera configuration is to use the
`lookup` function on a class parameter in a profile. For example:
```puppet
class profile::certbot (
  Stdlib::Email $email = lookup('profile::certbot::email'),
) {}
```

Hiera keys should be formed using the name of the profile and the
parameter, like in the example above. If a key is shared between
multiple profiles, use the shared part of the profile name (for example
`profile::puppet::some_param` for keys shared between
`profile::puppet::server` and `profile::puppet::puppetdb`), however use
`some_key` instead of `profile::some_key`.

Private Hiera data is stored in `/srv/git/puppet/private/` on the
Puppet server. For now, follow the instructions in `README` to edit.

## Managing user accounts

### Human users and groups

Human users are configured in `hieradata/common.yaml` with the
`profile::base::accounts` Hiera key and given UIDs starting from 1200.
Groups that are intended for human users should have GIDs starting
from 800.

#### Adding and removing users

To add a new user, add a new entry to `profile::base::accounts`. The
YAML array key is the Unix username, the standard restrictions apply
(so lowercase letters, numbers and dashes only, and start with a
letter). Other required settings are the numerical user ID (pick the
lowest available that's over 1200), list of groups the user is in
and SSH keys. Password authentication is not supported.

To remove a user, simply set `ensure: absent` and remove any groups and
SSH keys. Do not completely remove the user account definition.

#### Groups

A user can belong in one or more groups, and the user is provisioned
on all servers where that role is provisioned (which is controlled via
the `profile::base::enabled_groups` Hiera key). The `sudo` group grants
access to all jQuery servers, and using that is discouraged if you only
need access to a single service.

For example, to create a group for people managing the 'foo' service,
the steps needed for that are roughly:
* In `hieradata/common.yaml`, add the group definition into the
  `profile::base::groups` key. You need to at least assign a group ID
  (pick the lowest available number that's at least 800) and add sudo
  rules to the group. For example:
```yaml
profile::base::groups:
  foo-admins:
    gid: 802
    sudo:
      - "ALL = (root) NOPASSWD: /usr/local/sbin/run-puppet-agent"
      - "ALL = (root) NOPASSWD: /usr/bin/systemctl restart foo.service"
```
* In the role Hiera file for that service (in `hieradata/roles/`),
  add the group to `profile::base::enabled_groups`. For example:
```yaml
profile::base::enabled_groups: [foo-admins]
```
* Finally, add or modify user definitions in `hieradata/common.yaml`
  and add the new group to the users who need access.

### System user UID allocations

Statically assigned system UIDs and GIDs start from 600 and should be
documented here. They should be assigned using the `systemd::sysuser`
resource.

| UID | GID | name |
|-----|-----|------|
| 600 | 600 | gitpuppet
| 601 | 601 | notifier
| 602 | 602 | tarsnap

## Linting

See also <http://puppet-lint.com/checks/> and <https://github.com/rodjek/puppet-lint/>.

Install:
```
$ gem install puppet-lint -v '~> 2'
```

Run linter:
```shell-session
$ puppet-lint .
```

Autofix:
```shell-session
$ puppet-lint --fix .
```

## Testing changes (octocatalog-diff)

People with root access can use [octocatalog-diff] to test their
changes. To set it up, generate a password, convert it to the htpasswd
format using `htpasswd -n <username>` and add it to
`profile::puppet::puppetdb::nginx_htpassword_users` Hiera key in the
private repository (and remember to commit that change).

[octocatalog-diff]: https://github.com/github/octocatalog-diff/

Then, run octocatalog-diff like so:
```shell
$ export PUPPETDB_URL="https://username:password@puppet-03.ops.jquery.net:8100/"

$ octocatalog-diff -n codeorigin-02.stage.ops.jquery.net
$ octocatalog-diff --environment production -n puppet-03.ops.jquery.net
```

By default, `octocatalog-diff` will show the difference between the
current working tree and the last commit pushed to `origin`.

`octocatalog-diff` requires a local installation of Puppet 7. On a
Debian Bookworm (testing) setup, as of time of writing you need the
following packages:
```
octocatalog-diff
puppet-agent
puppet-module-puppetlabs-sshkeys-core
```
