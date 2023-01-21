# @summary manages a mariadb server installation
# @param $datadir directory where the database data is located
# @param $tmpdir directory used by mariadb for temporary data
# @param $innodb_buffer_pool_size amount of memory to allocate to the innodb buffer pool
# @param $bind_address address to bind the server on
# @param $bind_port port to bind on
# @param $max_connections number of simultaneous connections to allow
class mariadb::server (
  Stdlib::Unixpath    $datadir,
  Stdlib::Unixpath    $tmpdir,
  Optional[String[1]] $innodb_buffer_pool_size = undef,
  String[1]           $bind_address            = '127.0.0.1',
  Stdlib::Port        $bind_port               = 3306,
  Integer             $max_connections         = 128,
) {
  ensure_packages([
    'mariadb-server',
  ])

  file { [ $datadir, $tmpdir ]:
    ensure => directory,
    owner  => 'mysql',
    group  => 'mysql',
  }

  exec { 'mariadb-install-database':
    command   => "/usr/bin/mysql_install_db --user=mysql --datadir=${datadir}",
    creates   => "${datadir}/mysql",
    require   => File[$datadir],
    notify    => Service['mariadb'],
    logoutput => true,
  }

  file { '/etc/mysql/mariadb.cnf':
    ensure  => file,
    content => template('mariadb/server/mariadb.cnf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['mariadb'],
  }

  service { 'mariadb':
    ensure => running,
  }
}
