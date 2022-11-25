# @summary provisions a puppet server
class profile::puppet::server () {
  # TODO: manage the repository

  package { 'puppetserver':
    ensure => installed,
  }

  # TODO: manage config file

  service { 'puppetserver':
    ensure => running,
    enable => true,
  }

  nftables::allow { 'puppetserver':
    proto => 'tcp',
    dport => 8140,
  }
}
