# @summary configures the puppet agent
class profile::puppet::agent () {
  include ::profile::puppet::common

  package { 'puppet-agent':
    ensure => installed,
  }

  # TODO: manage config file

  service { 'puppet':
    ensure => running,
    enable => true,
  }

  file { '/usr/local/sbin/run-puppet-agent':
    ensure => file,
    source => 'puppet:///modules/profile/puppet/agent/run-puppet-agent.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0544',
  }
}
