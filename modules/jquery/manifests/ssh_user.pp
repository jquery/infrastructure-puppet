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
# String $key_type: "ssh-rsa", "ssh-ed25519", or something else.
#
# String $key: SSH public key.
#
# == Optional parameters
#
# Boolean $root: If true, add the user to the `sudo` group, and add their key to the `root` user.
#
define jquery::ssh_user(
    $ensure,
    $key_type,
    $key,
    $root = false,
  ) {

    if $root == true {
      $groups = ['sudo']
    } else {
      $groups = []
    }

    user { $name:
      ensure         => $ensure,
      password       => '*',
      managehome     => true,
      purge_ssh_keys => true,
      groups         => $groups,
      shell          => '/bin/bash'
    }

    ssh_authorized_key { "${name}_key":
      ensure => $ensure,
      user   => $name,
      type   => $key_type,
      key    => $key,
    }

    if $root == true {
      ssh_authorized_key { "root_${name}_key":
        ensure => $ensure,
        user   => 'root',
        type   => $key_type,
        key    => $key,
      }
    }

  }
