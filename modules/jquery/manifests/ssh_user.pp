#
# == Usage
#
#   @jquery::ssh_user { 'example':
#     ensure   => present,
#     key_type => 'ssh-rsa',
#     key      => '...',
#     password => '...',
#   }
#
#   @jquery::ssh_user { 'example':
#     ensure => absent,
#   }
#
# == Required parameters when present
#
# Ensure $ensure: present or absent.
#
# Integer $uid: The numeric UID of this user.
#
# String $key_type: "ssh-rsa", "ssh-ed25519", or something else.
#
# String $key: SSH public key.
#
# == Optional parameters
#
# Boolean $root: If true, add the user to the `sudo` group, and add their key to the `root` user.
#
define jquery::ssh_user(
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
