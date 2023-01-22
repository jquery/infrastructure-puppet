# @summary a testswarm server
class profile::testswarm::server (
  String[1]    $db_user_password = lookup('profile::testswarm::db_user_password'),
  String[1]    $tls_key_name     = lookup('profile::testswarm::server::tls_key_name'),
  Stdlib::Fqdn $public_host_name = lookup('profile::testswarm::server::public_host_name'),
) {
  git::clone { 'testswarm':
    path   => '/srv/testswarm',
    remote => 'https://github.com/jquery/testswarm',
    branch => 'main',
    owner  => 'root',
    group  => 'www-data',
  }

  file { '/srv/testswarm/cache':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0770',
    require => Git::Clone['testswarm'],
  }

  class { 'php::fpm': }

  $tls_config = nginx::tls_config()
  $php_fpm_version = $::php::fpm::version

  nginx::site { 'testswarm':
    content => template('profile/testswarm/server/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }
}
