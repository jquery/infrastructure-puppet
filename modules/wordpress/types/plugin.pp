# @summary represents a plugin to be installed
type Wordpress::Plugin = Struct[{
  name        => String[1],
  path        => Stdlib::Unixpath,
  single_file => Boolean,
}]
