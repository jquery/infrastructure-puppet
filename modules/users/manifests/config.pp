# @summary configures uid ranges allocated by adduser and systemd::sysusers
class users::config () {
  file { '/etc/adduser.conf':
    ensure => file,
    source => 'puppet:///modules/users/config/adduser.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
  }

  systemd::sysuser { 'base-config':
    source => 'puppet:///modules/users/config/sysusers.conf',
  }
}
