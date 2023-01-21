type Mariadb::User::Auth = Variant[
  Struct[{ unix_socket => Boolean }],
  Struct[{ password => String[1] }]
]
