# @summary creates a postgresql user
# @param $password password for this user
# @param $hba_entry pg_hba.conf line for this user account
# @param $ensure present or absent
define postgresql::user (
  String[1]     $password,
  String        $hba_entry,
  Jqlib::Ensure $ensure = present,
) {
  $user_sql = "SELECT rolname FROM pg_catalog.pg_roles WHERE rolname = '${title}'"
  $user_exists = "/usr/bin/test -n \"\$(/usr/bin/psql -At -c \"${user_sql}\")\""

  if $ensure == 'present' {
    exec { "postgresql-user-create-${title}":
      command => "/usr/bin/createuser --no-superuser --no-createdb --no-createrole ${title}",
      unless  => $user_exists,
      user    => 'postgres',
      notify  => Exec["postgresql-user-setpass-${title}"],
    }

    exec { "postgresql-user-setpass-${title}":
      command     => "/usr/bin/psql -c \"ALTER ROLE ${title} WITH PASSWORD '${password}';\"",
      user        => 'postgres',
      refreshonly => true,
    }

    concat::fragment { "pg-hba-${title}":
      content => "${hba_entry}\n",
      target  => "${::postgresql::conf_path}/pg_hba.conf",
      order   => '20',
    }
  } else {
    exec { "postgresql-user-drop-${title}":
      command => "/usr/bin/dropuser ${title}",
      onlyif  => $user_exists,
      user    => 'postgres',
    }
  }
}
