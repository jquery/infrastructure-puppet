# @summary manages the ssh server
class ssh::server (
  Boolean             $enable_ssh_ca,
  Array[Ssh::KeyType] $enabled_key_types = ['rsa', 'ecdsa', 'ed25519'],
) {
  package { 'openssh-server':
    ensure => installed,
  }

  $host_names = [
    $::facts['networking']['fqdn'],
    $::facts['networking']['ip'],
    $::facts['networking']['ip6'],
  ].flatten.filter |$x| {
    $x =~ NotUndef and !($x =~ /^fe80/)
  }.sort

  $enabled_key_types.each |Ssh::KeyType $type| {
    @@sshkey { "${::fqdn}-${type}":
      ensure       => present,
      name         => $::facts['networking']['fqdn'],
      type         => $::ssh[$type]['type'],
      key          => $::ssh[$type]['key'],
      host_aliases => $host_names.filter |$it| { $it != $::facts['networking']['fqdn'] },
    }

    if $enable_ssh_ca {
      ssh::server::ca_signed_hostkey { "/etc/ssh/ssh_host_${type}_key-cert.pub":
        hosts  => $host_names,
        type   => $type,
        notify => Service['sshd'],
      }
    }
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
