# @summary provisions a single user account
# @param $ensure present or absent.
# @param $uid The numeric UID of this user.
# @param $key_type "ssh-rsa", "ssh-ed25519", or something else.
# @param $key SSH public key.
# @param $root If true, add the user to the `sudo` group, and add their key to the `root` user.
define users::account(
  Enum['present', 'absent'] $ensure,
  Integer                   $uid,
  String                    $key_type,
  String                    $key,
  Boolean                   $root = false,
) {
  if $root {
    $groups = ['sudo']
  } else {
    $groups = []
  }

  group { $title:
    ensure => $ensure,
    gid    => $uid,
  }

  user { $title:
    ensure         => $ensure,
    uid            => $uid,
    gid            => $uid,
    password       => '*',
    managehome     => true,
    purge_ssh_keys => true,
    groups         => $groups,
    shell          => '/bin/bash',
  }

  ssh_authorized_key { "${title}_key":
    ensure => $ensure,
    user   => $title,
    type   => $key_type,
    key    => $key,
  }

  if $root {
    ssh_authorized_key { "root_${title}_key":
      ensure => $ensure,
      user   => 'root',
      type   => $key_type,
      key    => $key,
    }
  }
}
