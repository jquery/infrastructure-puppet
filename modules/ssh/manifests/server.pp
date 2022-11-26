# @summary manages the ssh server
class ssh::server () {
  package { 'openssh-server':
    ensure => installed,
  }

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('ssh/server/sshd_config.erb'),
    notify  => Service['sshd'],
  }

  service { 'sshd':
    ensure => running,
    enable => true,
  }

  nftables::allow { 'ssh':
    proto => 'tcp',
    dport => 22,
  }
}
