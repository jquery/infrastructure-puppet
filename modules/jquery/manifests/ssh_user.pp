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
# String $password: Linux user password, in salted SHA-512 hash.
#   You can generate this on Debian using the `mkpasswd` command
#   as `mkpasswd --method=SHA-512 --stdin`.
#
#   Or elsewhere with OpenSSL 1.1.1 or later (specify your own random salt)
#   as `openssl passwd -6 -salt xyzxyzxyz 'yourpass'`.
#
#   Or alternatively, if on LibreSSL (like macOS) or an older OpenSSL,
#   use PHP 7.4 or later `echo crypt('yourpass', '$6$'.bin2hex(random_bytes(4)));`
#
define jquery::ssh_user(
    $ensure,
    $key_type,
    $key,
    $password,
  ) {
    user { $name:
      ensure         => $ensure,
      managehome     => true,
      purge_ssh_keys => true,
      groups         => ['wheel'],
      require        => Group['wheel'],
      shell          => '/bin/bash'
    }

    if $ensure == 'present' {
      User[$name] {
        password => $password,
      }

      ssh_authorized_key { "${name}_key":
        ensure => $ensure,
        user   => $name,
        type   => $key_type,
        key    => $key,
      }
    }

  }
