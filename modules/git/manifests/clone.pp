# @summary clones a git repository
# @param $path the filesystem path
# @param $remote the remote url
# @param $branch the branch or tag to checkout
# @param $owner file owner
# @param $group file group
# @param $shared true if the group should have write access
# @param $ensure present or absent
# @param $update Enable this to update an existing clone after $branch points to
#  a different tag than before. Only supports tags. This will *delete* any ignored
#  or untracked files (such as previously provisioned configuration or node_modules).
#  To update after branch pushes, use `notifier` instead.
define git::clone (
  Stdlib::Unixpath $path,
  String           $remote,
  String           $branch,
  String           $owner,
  String           $group,
  Boolean          $shared = false,
  Jqlib::Ensure    $ensure = present,
  Boolean          $update = false,
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

    if $update {
      exec { "git_checkout_${title}":
        cwd       => $path,
        unless    => "test \"$(git describe --exact-match --tags) = \"${branch}\"",
        # This will delete
        command   => "/usr/bin/git fetch --tags --prune --prune-tags \"${remote}\" && /usr/bin/git checkout --force --quiet \"${branch}\" && /usr/bin/git clean -dfx",
        logoutput => true,
        provider  => 'shell',
        user      => $owner,
        group     => $group,
        umask     => $umask,
      }
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
