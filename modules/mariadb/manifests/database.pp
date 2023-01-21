# @summary creates a mariadb database
# @param $database the database name
define mariadb::database (
  String[1] $database = $title,
) {
  mariadb::command { "create-db-${database}":
    sql    => "CREATE DATABASE ${database}",
    unless => "SELECT 1 FROM information_schema.schemata WHERE schema_name = '${database}'",
  }
}
