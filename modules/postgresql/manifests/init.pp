# @summary manages a postgres install
class postgresql () {
  $cluster_name = 'main'
  $pg_version = debian::codename() ? {
    'bullseye' => '13',
    'bookworm' => '15',
  }

  ensure_packages([
    "postgresql-${pg_version}",
  ])

  $conf_path = "/etc/postgresql/${pg_version}/${cluster_name}"

  concat { "${conf_path}/pg_hba.conf":
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0444',
    notify => Service["postgresql@${pg_version}-${cluster_name}"],
  }

  concat::fragment { 'pg-hba-base':
    source => 'puppet:///modules/postgresql/base_hba.conf',
    target => "${conf_path}/pg_hba.conf",
    order  => '10',
  }

  service { "postgresql@${pg_version}-${cluster_name}":
    ensure => running,
    enable => true,
  }
}
