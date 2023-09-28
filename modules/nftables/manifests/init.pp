# @summary manages the nftables firewall
class nftables () {
  package { 'nftables':
    ensure => present,
  }

  file { '/etc/nftables.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/nftables/init.nft',
    require => Package['nftables'],
    notify  => Service['nftables'],
  }

  file { '/etc/nftables/':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nftables'],
    notify  => Service['nftables'],
  }

  service { 'nftables':
    ensure  => running,
    enable  => true,
    require => Package['nftables'],
  }

  File <| tag == 'nftables' |>

  nftables::conf { 'base':
    source   => 'puppet:///modules/nftables/base.nft',
    priority => 01,
  }
}
