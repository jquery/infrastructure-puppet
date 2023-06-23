type Profile::Miscweb::Redirect = Struct[{
  target      => Stdlib::HTTPSUrl,
  mode        => Enum['prefix', 'root'],
  certificate => Optional[String[1]],
  permanent   => Optional[Boolean],
}]
