type Wordpress::User = Struct[{
  username => String[1],
  password => String[1],
  email    => Stdlib::Email,
  role     => String[1],
}]
