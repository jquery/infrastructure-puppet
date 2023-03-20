type Profile::Wordpress::Blogs::Sites = Hash[
  String[1],
  Struct[{
    host        => Stdlib::Fqdn,
    certificate => String[1],
  }],
]
