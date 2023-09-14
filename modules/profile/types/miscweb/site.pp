type Profile::Miscweb::Site = Struct[{
  repository   => Struct[{
    name   => String[1],
    branch => String[1],
  }],
  webroot      => Optional[String[1]],
  extra_config => Optional[String[1]],
  notifier     => Optional[Boolean],
  allow_php    => Optional[Boolean],
  php_env      => Optional[Hash[String[1], String]],
  certificate  => Optional[String[1]],
}]
