# @summary manages the shared config file for puppet
class profile::puppet::common () {
  $config_file = '/etc/puppet/puppet.conf'

  concat { $config_file:
    ensure => present,
    mode   => '0444',
    owner  => 'root',
    group  => 'root',
  }
}
