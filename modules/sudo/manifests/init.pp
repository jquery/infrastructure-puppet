# @summary manages sudo rules
class sudo () {
  package { 'sudo':
    ensure => present,
  }

  file { '/etc/sudoers':
    ensure => present,
    mode   => '0440',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/sudo/sudoers',
  }

  file { '/etc/sudoers.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
  }
}
