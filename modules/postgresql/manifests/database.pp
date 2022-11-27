# @summary creates a postgresql database
# @param $owner postgresql user who owns the database
# @param $ensure present or absent
define postgresql::database (
  String[1]     $owner,
  Jqlib::Ensure $ensure = present,
) {
  $db_sql = "SELECT datname FROM pg_catalog.pg_database WHERE datname = '${title}'"
  $db_exists = "/usr/bin/test -n \"\$(/usr/bin/psql -At -c \"${db_sql}\")\""

  if $ensure == 'present' {
    exec { "postgresql-db-create-${title}":
      command => "/usr/bin/createdb --owner ${owner} ${title}",
      unless  => $db_exists,
      user    => 'postgres',
    }
  } else {
    exec { "postgresql-db-drop-${title}":
      command => "/usr/bin/dropdb ${title}",
      onlyif  => $db_exists,
      user    => 'postgres',
    }
  }
}
