# @summary gives a mariadb user some grants on some database
# @param $user_name the user name
# @param $user_host the user host
# @param $database the database name
# @param $grants the individual grants to give
define mariadb::grant (
  String[1]       $user_name,
  String[1]       $user_host,
  String[1]       $database,
  Mariadb::Grants $grants,
) {
  $user = "'${user_name}'@'${user_host}'"

  if $database == '*' {
    $from_where = 'user_privileges WHERE'
  } else {
    $from_where = "schema_privileges WHERE table_schema = '${database}' AND"
  }

  if $grants =~ Array[String] {
    $grants.each |$grant| {
      mariadb::command { "grant-${user_name}-${user_host}-${database}-${grant}":
        sql    => "GRANT ${grant} ON ${database}.* TO ${user}",
        unless => "SELECT 1 FROM information_schema.${from_where} grantee = \"${user}\" AND privilege_type = '${grant}'",
      }
    }
  } elsif $grants['all'] {
    mariadb::command { "grant-${user_name}-${user_host}-${database}":
      sql    => "GRANT ALL PRIVILEGES ON ${database}.* TO ${user}",
      unless => "SELECT 1 FROM information_schema.${from_where} grantee = \"${user}\"",
    }
  } else {
    fail('mariadb::grant: invalid $grants param')
  }
}
