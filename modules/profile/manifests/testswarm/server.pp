# @summary a testswarm server
class profile::testswarm::server (
  String[1]                       $db_user_password   = lookup('profile::testswarm::db_user_password'),
  Stdlib::Fqdn                    $public_host_name   = lookup('profile::testswarm::public_host_name'),
  String[1]                       $run_token          = lookup('profile::testswarm::run_token'),
  String[1]                       $tls_key_name       = lookup('profile::testswarm::server::tls_key_name'),
  Stdlib::Fqdn                    $builds_server_name = lookup('profile::testswarm::server::builds_server_name'),
  Jqlib::Ensure                   $cleanup_ensure     = lookup('profile::testswarm::server::cleanup_ensure'),
  Profile::TestSwarm::UserAgents  $user_agents        = lookup('profile::testswarm::server::settings::user_agents'),
  Profile::TestSwarm::BrowserSets $browser_sets       = lookup('profile::testswarm::server::settings::browser_sets'),
) {
  class { 'php':
    extensions => ['mysql'],
  }

  class { 'php::fpm':
    ini_values_extra => {
      'memory_limit' => '512M',
    },
  }

  git::clone { 'testswarm':
    path   => '/srv/testswarm',
    remote => 'https://github.com/jquery/testswarm',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  file { '/srv/testswarm/cache':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0770',
    require => Git::Clone['testswarm'],
  }

  $config = {
    database    => {
      host     => '127.0.0.1',
      database => 'testswarm',
      username => 'testswarm',
      password => $db_user_password,
    },
    web         => {
      server             => "https://${public_host_name}",
      contentpath        => '/',
      title              => "jQuery's TestSwarm",
      ajaxUpdateInterval => 4,
    },
    client      => {
      cooldownSleep  => 0,
      nonewrunsSleep => 10,
      runTimeout     => 600,
      runTokenHash   => sha1($run_token),
      refreshControl => 4,
    },
    userAgents  => $user_agents,
    browserSets => $browser_sets,
    storage     => {
      cacheDir => '/srv/testswarm/cache',
    },
    debug       => {
      showExceptionDetails => false,
      phpErrorReporting    => false,
      dbLogQueries         => false,
    },
  }

  file { '/etc/testswarm.json':
    ensure    => file,
    content   => $config.to_json(),
    owner     => 'www-data',
    group     => 'www-data',
    mode      => '0440',
    show_diff => false,
  }

  file { '/srv/testswarm/config/localSettings.php':
    ensure    => file,
    source    => 'puppet:///modules/profile/testswarm/server/localSettings.php',
    owner     => 'www-data',
    group     => 'www-data',
    mode      => '0440',
    require   => Git::Clone['testswarm'],
    show_diff => false,
  }

  file { '/srv/testswarm/robots.txt':
    ensure  => link,
    target  => '/srv/testswarm/config/sample-robots.txt',
    require => Git::Clone['testswarm'],
  }

  $tls_config = nginx::tls_config()
  $php_fpm_version = $::php::fpm::version

  nginx::site { 'testswarm':
    content => template('profile/testswarm/server/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }

  nftables::allow { 'testswarm-https':
    proto => 'tcp',
    dport => 443,
  }

  # High-priority TestSwarm jobs (every minute at *:30s)
  #
  # This is for resetting timed-out browsers and other urgent jobs.
  # During a migration between servers, you may want to turn this off
  # so that both servers don't instruct the same public URL.
  systemd::timer { 'testswarm-cleanup':
    ensure      => $cleanup_ensure,
    description => 'TestSwarm urgent jobs',
    user        => 'root',
    command     => "/usr/bin/curl -s https://${public_host_name}/api.php?action=cleanup",
    interval    => ['OnCalendar=*-*-* *:*:30'],
  }

  # Low-priority TestSwarm jobs (daily)
  #
  # This is for pruning data older than ~ 6 months (200 days),
  # to keep the database size somewhat under control.
  #
  # https://github.com/jquery/infrastructure/issues/339
  # https://github.com/jquery/infrastructure/issues/535
  systemd::timer { 'testswarm-prune':
    ensure      => present,
    description => 'TestSwarm database pruning',
    user        => 'root',
    command     => '/usr/bin/php /srv/testswarm/scripts/purge.php --maxage=200 --quick',
    interval    => ['OnCalendar=*-*-* 14:50:50'],
  }
}
