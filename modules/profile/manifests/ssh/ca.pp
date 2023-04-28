# @summary provision
class profile::ssh::ca () {
  file { '/etc/ssh-ca':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0500',
  }

  file { '/etc/ssh-ca/ca':
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => jqlib::secret('ssh_ca/ca'),
  }

  file { '/etc/ssh-ca/ca.pub':
    ensure  => file,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => jqlib::secret('ssh_ca/ca.pub'),
  }
}
