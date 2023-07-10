# @summary manages the shared parts of puppet (apt repo and shared config)
class profile::puppet::common () {
  if debian::codename() == 'bullseye' {
    file { '/etc/apt/keyrings/puppet.gpg':
      ensure => file,
      source => 'puppet:///modules/profile/puppet/common/keyring.gpg',
    }

    apt::source { 'puppet':
      location => 'https://apt.puppet.com',
      repos    => 'puppet7',
      keyring  => '/etc/apt/keyrings/puppet.gpg',
      pin      => 150,
    }

    $config_path = '/etc/puppetlabs/puppet'
  } else {
    $config_path = '/etc/puppet'
  }

  $config_file = "${config_path}/puppet.conf"

  concat { $config_file:
    ensure => present,
    mode   => '0444',
    owner  => 'root',
    group  => 'root',
  }
}
