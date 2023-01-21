# @summary gives a mariadb user some grants on some database
# @param $user_name the user name
# @param $user_host the user host
# @param $database the database name
# @param $grants the individual grants to give
define mariadb::grant (
  String[1]             $user_name,
  String[1]             $user_host,
  String[1]             $database,
  Array[Mariadb::Grant] $grants,
) {
  $user = "'${user_name}'@'${user_host}'"

  $grants.each |Mariadb::Grant $grant| {
    mariadb::command { "grant-${user_name}-${user_host}-${database}-${grant}":
      sql    => "GRANT ${grant} ON ${database}.* TO ${user}",
      unless => "SELECT 1 FROM information_schema.schema_privileges WHERE grantee = \"${user}\" AND table_schema = '${database}' AND privilege_type = '${grant}'",
    }
  }
}
