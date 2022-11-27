# @summary installs a postgresql extension
define postgresql::extension (
  String[1] $extension,
  String[1] $database,
) {
  $ext_sql = "SELECT extname FROM pg_catalog.pg_extension WHERE extname = '${extension}'"
  $ext_exists = "/usr/bin/test -n \"\$(/usr/bin/psql ${database} -At -c \"${ext_sql}\")\""

  exec { "postgresql-extension-create-${title}":
    command => "/usr/bin/psql ${database} -c \"CREATE EXTENSION ${extension};\"",
    unless  => $ext_exists,
    user    => 'postgres',
  }
}
