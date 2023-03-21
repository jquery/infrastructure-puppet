# @summary represents a theme to be installed
type Wordpress::Theme = Struct[{
  name => String[1],
  path => Stdlib::Unixpath,
}]
