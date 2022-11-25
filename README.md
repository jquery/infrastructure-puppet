[![CI status](https://github.com/jquery/infrastructure-puppet/actions/workflows/CI.yaml/badge.svg)](https://github.com/jquery/infrastructure-puppet/actions/workflows/CI.yaml)

# infrastructure-puppet

Puppet configuration for jQuery Infrastructure servers.

## Install

This repository represents `/etc/puppetlabs/code/` on a puppet server.

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
