type Profile::Docs::Redirect = Struct[{
  match     => Struct[{
    path => String[1],
    mode => Enum['exact', 'prefix']
  }],
  target    => Struct[{
    url  => Stdlib::HTTPSUrl,
    mode => Enum['exact', 'prefix'],
  }],
  permanent => Optional[Boolean],
}]
