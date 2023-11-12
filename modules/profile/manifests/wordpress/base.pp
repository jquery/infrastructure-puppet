# @summary common config for any wordpress site
class profile::wordpress::base (
  String[1]           $innodb_buffer_pool_size = lookup('profile::wordpress::base::mariadb_innodb_buffer_pool_size', {default_value => '512M'}),
  String[1]           $wordpress_cli_version   = lookup('profile::wordpress::base::wordpress_cli_version'),
  Optional[String[1]] $default_site_cert       = lookup('profile::wordpress::base::default_site_cert', {default_value => undef}),
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
      'apcu',
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
      'memory_limit' => '64M',
    },
  }

  class { 'wordpress::cli':
    version => $wordpress_cli_version,
  }

  # Provision a default site on port 443, so that all the crawlers hitting
  # the HTTPS port without a real host name don't end up hitting WordPress/PHP
  # and consuming resources.
  if $default_site_cert {
    $tls_config = nginx::tls_config()
    nginx::site { 'default-tls':
      content => template('profile/wordpress/base/default-tls.nginx.erb'),
    }
  }
}
