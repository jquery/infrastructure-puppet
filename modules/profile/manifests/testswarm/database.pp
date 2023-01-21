# @summary provisions mariadb database for testswarm
class profile::testswarm::database (
  String[1] $innodb_buffer_pool_size = lookup('profile::testswarm::database::innodb_buffer_pool_size', {default_value => '512M'}),
) {
  file { '/srv/mariadb':
    ensure => directory,
  }

  class { 'mariadb::server':
    datadir                 => '/srv/mariadb/data',
    tmpdir                  => '/srv/mariadb/tmp',
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
  }
}
