# @summary manages the ssh server
class ssh::server (
  Boolean             $enable_ssh_ca,
  Array[Ssh::KeyType] $enabled_key_types = ['rsa', 'ecdsa', 'ed25519'],
) {
  package { 'openssh-server':
    ensure => installed,
  }

  if $enable_ssh_ca {
    $trusted_host_names = [
      $::facts['networking']['fqdn'],
      $::facts['networking']['hostname'],
      $::facts['networking']['ip'],
      $::facts['networking']['ip6'],
    ].flatten.filter |$x| {
      $x =~ NotUndef and !($x =~ /^fe80/)
    }.sort

    $enabled_key_types.each |Ssh::KeyType $type| {
      ssh::server::ca_signed_hostkey { "/etc/ssh/ssh_host_${type}_key-cert.pub":
        hosts  => $trusted_host_names,
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
