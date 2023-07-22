type Profile::Miscweb::Site = Struct[{
  repository   => Struct[{
    name   => String[1],
    branch => String[1],
  }],
  webroot      => Optional[String[1]],
  extra_config => Optional[String[1]],
  allow_php    => Optional[Boolean],
  certificate  => Optional[String[1]],
}]
