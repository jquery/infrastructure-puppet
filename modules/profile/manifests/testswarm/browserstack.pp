# @summary configures the testswarm-browserstack connector
class profile::testswarm::browserstack (
  Stdlib::Fqdn  $public_host_name  = lookup('profile::testswarm::public_host_name'),
  String[1]     $browserstack_user = lookup('profile::testswarm::browserstack::browserstack_user'),
  String[1]     $browserstack_key  = lookup('profile::testswarm::browserstack::browserstack_key'),
  String[1]     $run_token         = lookup('profile::testswarm::browserstack::run_token'),
  Jqlib::Ensure $ensure            = lookup('profile::testswarm::browserstack::ensure'),
) {
  ensure_packages(['nodejs', 'npm'])

  git::clone { 'testswarm-browserstack':
    path   => '/srv/testswarm-browserstack',
    remote => 'https://github.com/jquery/testswarm-browserstack',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  exec { 'testswarm-browserstack-npm-install':
    command => '/usr/bin/npm install --cache /tmp/npm-testswarm-browserstack',
    cwd     => '/srv/testswarm-browserstack',
    creates => '/srv/testswarm-browserstack/node_modules',
    user    => 'www-data',
    require => Git::Clone['testswarm-browserstack'],
  }

  $config = {
    browserstack => {
      user => $browserstack_user,
      pass => $browserstack_key,
    },
    testswarm    => {
      root   => "https://${public_host_name}",
      runUrl => "https://${public_host_name}/run/browserstack?run_token=${run_token}",
    },
  }

  file { '/etc/testswarm-browserstack.json':
    ensure    => file,
    content   => $config.to_json(),
    owner     => 'www-data',
    group     => 'www-data',
    mode      => '0440',
    show_diff => false,
  }

  systemd::service { 'testswarm-browserstack':
    ensure  => $ensure,
    content => template('profile/testswarm/browserstack/testswarm-browserstack.service.erb'),
  }

  $restart_services = $ensure ? {
    present => ['testswarm-browserstack.service'],
    default => [],
  }

  notifier::git_update { 'testswarm-browserstack':
    github_repository => 'jquery/testswarm-browserstack',
    listen_for        => [{ branch => 'main' }],
    local_path        => '/srv/testswarm-browserstack',
    local_user        => 'www-data',
    extra_commands    => ['/usr/bin/npm install --prefix /srv/testswarm-browserstack --cache /tmp/npm-testswarm-browserstack'],
    restart_services  => $restart_services,
  }
}
