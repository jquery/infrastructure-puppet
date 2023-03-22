# @summary configures backups for mariadb databases
class tarsnap::mariadb (
  String[1] $database_pattern,
) {
  mariadb::user { 'tarsnap':
    host => 'localhost',
    auth => { unix_socket => true },
  }

  mariadb::grant { 'tarsnap':
    user_name => 'tarsnap',
    user_host => 'localhost',
    database  => '*',
    grants    => [
      'SELECT',
      'SHOW VIEW',
      'RELOAD',
      'EVENT',
      'TRIGGER',
      'LOCK TABLES',
    ],
  }

  file { '/var/lib/backup/mariadb':
    ensure => directory,
    owner  => 'tarsnap',
    group  => 'tarsnap',
    mode   => '0755',
  }

  file { '/usr/local/bin/jq-tarsnap-dump-mariadb':
    ensure => file,
    source => 'puppet:///modules/tarsnap/mariadb/jq-tarsnap-dump-mariadb.sh',
    mode   => '0555',
  }

  tarsnap::backup { 'mariadb':
    paths               => ['/var/lib/backup/mariadb'],
    take_backup_command => "/usr/bin/sudo -u tarsnap /usr/local/bin/jq-tarsnap-dump-mariadb ${database_pattern}"
  }
}
