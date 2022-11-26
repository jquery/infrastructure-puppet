# @summary manages the user accounts on this system
# @param $accounts all user account data
# @param $groups all group data
# @param $enabled_groups groups enabled on this host
class users (
  Hash[String, Hash] $accounts,
  Array[String]      $enabled_groups,
  Hash[String, Hash] $groups,
) {
  class { 'users::config': }
    # get the configuration added before packages get the chance to add new users
    -> Package <| |>

  # https://voxpupuli.org/blog/2014/08/24/purging-ssh-authorized-keys/
  # https://github.com/jquery/infrastructure/issues/531
  user { 'root':
    ensure         => present,
    home           => '/root',
    uid            => 0,
    purge_ssh_keys => true,
  }

  $groups.each |String $name, Hash $data| {
    if $name in $enabled_groups {
      users::group { $name:
        * => $data,
      }
    }
  }

  $accounts.each |String $username, Hash $account| {
    $user_groups = $account['groups'].map |String $group| {
      if 'include' in $groups[$group] {
        [$group] + $groups[$group]['include']
      } else {
        [$group]
      }
    }.flatten.filter |String $group| {
      $group in $enabled_groups
    }

    $is_root = !$user_groups.filter |String $group| {
      $groups[$group]['root']
    }.empty

    $posix_groups = $user_groups.map |String $group| {
      if 'posix' in $groups[$group] {
        $groups[$group]['posix']
      } else {
        $group
      }
    }

    users::account { $username:
      user_groups => $posix_groups,
      root        => $is_root,
      *           => $account,
    }
  }
}
