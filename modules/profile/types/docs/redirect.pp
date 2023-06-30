type Profile::Docs::Redirect = Struct[{
  path      => String[1],
  match     => Enum['exact', 'prefix'],
  target    => Stdlib::HTTPSUrl,
  permanent => Optional[Boolean],
}]
