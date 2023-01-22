# @summary a testswarm server
class profile::testswarm::server (
  String[1]    $db_user_password = lookup('profile::testswarm::db_user_password'),
  String[1]    $tls_key_name     = lookup('profile::testswarm::server::tls_key_name'),
  Stdlib::Fqdn $public_host_name = lookup('profile::testswarm::server::public_host_name'),
  Hash         $user_agents      = lookup('profile::testswarm::server::settings::user_agents'),
  Hash         $browser_sets     = lookup('profile::testswarm::server::settings::browser_sets'),
) {
  class { 'php::fpm': }

  ensure_packages([
    'composer',
  ])

  git::clone { 'testswarm':
    path   => '/srv/testswarm',
    remote => 'https://github.com/jquery/testswarm',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  exec { 'testswarm-composer-install':
    command => '/usr/bin/composer install --no-dev',
    cwd     => '/srv/testswarm',
    creates => "/srv/testswarm/vendor",
    user    => 'www-data',
    require => Git::Clone['testswarm'],
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
      cooldownSleep   => 0,
      nonewrunsSleep  => 10,
      runTimeout      => 600,
      requireRunToken => true,
      refreshControl  => 4,
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
    ensure  => file,
    content => $config.to_json(),
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0440',
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
    ensure => link,
    target => '/srv/testswarm/config/sample-robots.txt',
    require => Git::Clone['testswarm'],
  }

  $tls_config = nginx::tls_config()
  $php_fpm_version = $::php::fpm::version

  nginx::site { 'testswarm':
    content => template('profile/testswarm/server/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }
}
