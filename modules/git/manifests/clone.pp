# @summary clones a git repository
# @param $path the filesystem path
# @param $remote the remote url
# @param $branch the branch to clone
# @param $owner file owner
# @param $group file group
# @param $shared true if the group should have write access
# @param $ensure present or absent
define git::clone (
  Stdlib::Unixpath $path,
  String           $remote,
  String           $branch,
  String           $owner,
  String           $group,
  Boolean          $shared = false,
  Jqlib::Ensure    $ensure = present,
) {
  if $ensure == 'present' {
    if $shared {
      $mode       = '2775'
      $shared_arg = '-c core.sharedRepository=group'
      $umask      = '002'
    } else {
      $mode       = '0755'
      $shared_arg = ''
      $umask      = '022'
    }

    file { $path:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }

    exec { "git_clone_${title}":
      command => "/usr/bin/git ${shared_arg} clone -b ${branch} ${remote} ${path}",
      cwd     => '/',
      creates => "${path}/.git",
      user    => $owner,
      group   => $group,
      umask   => $umask,
    }
  } elsif $ensure == 'absent' {
    file { $path:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  } else {
    fail('unsupported ensure param')
  }
}
