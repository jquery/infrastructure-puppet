# @summary provisions a puppetdb server
class profile::puppet::puppetdb_database (
  String[1] $postgresql_password = lookup('profile::puppet::puppetdb::postgresql_password'),
) {
  class { 'postgresql': }

  postgresql::extension { 'puppetdb-pg_trgm':
    extension => 'pg_trgm',
    database  => 'puppetdb',
  }

  postgresql::user { 'puppetdb':
    password  => $postgresql_password,
    hba_entry => 'host puppetdb puppetdb 127.0.0.1/32 md5',
  }

  postgresql::database { 'puppetdb':
    owner => 'puppetdb',
  }
}
