type Profile::Wordpress::Blogs::Sites = Hash[
  String[1],
  Struct[{
    host                => Stdlib::Fqdn,
    site_name           => String[1],
    certificate         => String[1],
    active_theme        => String[1],
    permalink_structure => Optional[String[1]],
  }],
]
