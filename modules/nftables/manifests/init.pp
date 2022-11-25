# @summary manages the nftables firewall
class nftables () {
  package { 'nftables':
    ensure => present,
  }

  file { '/etc/nftables.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
    source => 'puppet:///modules/nftables/init.nft',
    notify => Service['nftables'],
  }

  file { '/etc/nftables/':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['nftables'],
  }

  service { 'nftables':
    enable => false,
    #ensure => running,
    #enable => true,
  }

  File <| tag == 'nftables' |>

  nftables::conf { 'base':
    source   => 'puppet:///modules/nftables/base.nft',
    priority => 01,
  }

  nftables::conf { 'base-end':
    source   => 'puppet:///modules/nftables/base-end.nft',
    priority => 99,
  }
}
