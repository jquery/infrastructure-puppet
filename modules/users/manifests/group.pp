# @summary a system group
# @param $gid for custom groups, a group id to use
# @param $posix posix name of the group, if other than the title
# @param $root if true, members of this group will be in the adm group
#   and have their ssh key added to the root user
# @param $sudo sudo rules for this group
# @param $include the members of this group will be added to these also
define users::group (
  Optional[Integer] $gid     = undef,
  Optional[String]  $posix   = undef,
  Boolean           $root    = false,
  Array[String]     $sudo    = [],
  Array[String]     $include = [],
) {
  $group_name = $posix ? {
    undef   => $title,
    default => $posix,
  }

  group { $group_name:
    ensure => present,
    gid    => $gid,
    system => true,
  }

  sudo::rule { "group-${group_name}":
    ensure     => present,
    target     => "%${group_name}",
    privileges => $sudo,
  }
}
