# @summary provisions mariadb database for testswarm
class profile::testswarm::database (
  String[1] $innodb_buffer_pool_size = lookup('profile::testswarm::database::innodb_buffer_pool_size', {default_value => '512M'}),
  String[1] $db_user_password        = lookup('profile::testswarm::db_user_password'),
) {
  file { '/srv/mariadb':
    ensure => directory,
  }

  class { 'mariadb::server':
    datadir                 => '/srv/mariadb/data',
    tmpdir                  => '/srv/mariadb/tmp',
    innodb_buffer_pool_size => $innodb_buffer_pool_size,
  }

  mariadb::database { 'testswarm': }

  mariadb::user { 'testswarm':
    host => '127.0.0.1',
    auth => { password => $db_user_password },
  }

  mariadb::grant { 'testswarm':
    user_name => 'testswarm',
    user_host => '127.0.0.1',
    database  => 'testswarm',
    grants    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
  }
}
