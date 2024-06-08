# @summary Generates an SSH keypair in a way that the public part will
#  be available as a fact for use elsewhere.
define ssh::client::user_key (
  String[1] $owner = 'root',
  String[1] $group = 'root',
) {
  exec { "ssh-key-generate-${title}":
    command => "/usr/bin/ssh-keygen -f /etc/ssh/local_keys.d/${title} -C '${title} ${facts['networking']['fqdn']}' -t ed25519",
    creates => "/etc/ssh/local_keys.d/${title}",
    user    => $owner,
    group   => $group,
  }

  file { "/etc/ssh/local_keys.d/${title}":
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0400',
    require => Exec["ssh-key-generate-${title}"],
  }

  file { "/etc/ssh/local_keys.d/${title}.pub":
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0444',
    require => File["/etc/ssh/local_keys.d/${title}"],
  }
}
