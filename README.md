[![CI status](https://github.com/jquery/infrastructure-puppet/actions/workflows/CI.yaml/badge.svg)](https://github.com/jquery/infrastructure-puppet/actions/workflows/CI.yaml)

# infrastructure-puppet

Puppet configuration for jQuery Infrastructure servers.

## Install

This repository is installed onto Puppet servers using the
`puppet::server` profile, applied via the `puppet` role. To apply
updates to this repository, SSH to the Puppet server and run
`puppet-merge` as your local user.

## Provisioning new nodes

Add the instance to `site.pp`, `puppet-merge` that commit and use the
`bin/provision-instance.sh` script on your local machine:
```bash
$ bin/provision-instance.sh codeorigin-02.stage.ops.jquery.net staging
```

## Running Puppet manually
There is a wrapper script `run-puppet-agent` that should be used
instead of directly executing `puppet agent -tv`.

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

## UID allocations

Human users are assigned UIDs starting with 1200. These are configured
in `hieradata/common.yaml`.

Statically assigned system UIDs and GIDs start from 600 and should be
documented here. They should be assigned using the `systemd::sysuser`
resource.

| UID | GID | name |
|-----|-----|------|
| 600 | 600 | gitpuppet
| 601 | 601 | notifier

## Contributing

### Linting

See also <http://puppet-lint.com/checks/> and <https://github.com/rodjek/puppet-lint/>.

Install:
```
gem install puppet-lint -v '~> 2'
```

Run linter:
```
puppet-lint .
````

Autofix:
```
puppet-lint --fix .
```

### Testing changes (octocatalog-diff)

People with root access can use [octocatalog-diff] to test their
changes. To set it up, generate a password, convert it to the htpasswd
format using `htpasswd -n <username>` and add it to
`profile::puppet::puppetdb::nginx_htpassword_users` Hiera key in the
private repository (and remember to commit that change).

[octocatalog-diff]: https://github.com/github/octocatalog-diff/

Then, run octocatalog-diff like so:
```shell
$ export PUPPETDB_URL="https://username:password@puppet-03.stage.ops.jquery.net:8100/"
$ octocatalog-diff -n puppet-03.stage.ops.jquery.net
I, [2022-11-28T16:06:24.469527 #199545]  INFO -- : Catalogs compiled for puppet-03.stage.ops.jquery.net
I, [2022-11-28T16:06:24.512173 #199545]  INFO -- : Diffs computed for puppet-03.stage.ops.jquery.net
I, [2022-11-28T16:06:24.512213 #199545]  INFO -- : No differences
```

By default, `octocatalog-diff` will show the difference between the
current working tree and the last commit pushed to `origin`.
