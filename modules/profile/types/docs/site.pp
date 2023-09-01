type Profile::Docs::Site = Struct[{
  host                   => Stdlib::Host,
  path                   => Optional[Wordpress::Path],
  site_name              => String[1],
  repository             => Struct[{
    name       => String[1],
    branch     => String[1],
    tag_format => Optional[String[1]],
  }],
  certificate            => String[1],
  active_theme           => String[1],
  builder_extra_settings => Optional[Hash],
  enable_static_index    => Optional[Boolean],
  enable_api_tweaks      => Optional[Boolean],
  extra_config           => Optional[String[1]],
  redirects              => Optional[Array[Profile::Docs::Redirect]],
  proxies                => Optional[Array[Profile::Docs::Proxy]],
}]
