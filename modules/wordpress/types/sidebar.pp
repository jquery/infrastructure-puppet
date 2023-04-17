# @summary represents a sidebar to be managed
type Wordpress::Sidebar = Struct[{
  slot   => String[1],
  ensure => Enum['absent'],
}]
