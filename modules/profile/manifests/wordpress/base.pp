# @summary common config for any wordpress site
class profile::wordpress::base (
  String[1] $innodb_buffer_pool_size = lookup('profile::wordpress::base::mariadb_innodb_buffer_pool_size', {default_value => '512M'}),
  String[1] $wordpress_cli_version   = lookup('profile::wordpress::base::wordpress_cli_version'),
) {
  file { '/srv/mariadb':
    ensure => directory,
  }

  class { 'mariadb::server':
    datadir                 => '/srv/mariadb/data',
    tmpdir                  => '/srv/mariadb/tmp',
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
  }

  file { [
    '/srv/wordpress',
    '/srv/wordpress/sites'
  ]:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  }

  class { 'php':
    extensions => [
      # https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions
      'curl',
      { package => 'php-imagick' },
      'intl',
      'mbstring',
      'mysql',
      'xml',
      'zip',
    ],
  }

  class { 'php::fpm':
    ini_values_extra => {
      'memory_limit' => '512M',
    },
  }

  class { 'wordpress::cli':
    version => $wordpress_cli_version,
  }
}
