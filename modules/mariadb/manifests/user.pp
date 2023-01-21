# @summary creates a mariadb user
# @param $auth authentication details for this user
# @param $name user name
# @param $host host
define mariadb::user (
  Mariadb::User::Auth $auth,
  String[1]           $host,
) {
  if $auth['unix_socket'] {
    $identified = 'VIA unix_socket'
  } elsif $auth['password'] {
    $identified = "BY '${auth['password']}'"
  } else {
    fail('invalid auth data')
  }

  mariadb::command { "create-user-${name}-${host}":
    sql    => "CREATE USER '${name}'@'${host}' IDENTIFIED ${identified}",
    unless => "SELECT 1 FROM mysql.user WHERE user = '${name}' AND host = '${host}'",
  }
}
