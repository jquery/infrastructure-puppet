# @summary configures the puppet agent
class profile::puppet::agent (
  Stdlib::Fqdn $puppet_server = lookup('profile::puppet::agent::puppet_server'),
) {
  include ::profile::puppet::common

  package { 'puppet-agent':
    ensure => installed,
  }

  concat::fragment { 'puppet-config-agent':
    target  => $::profile::puppet::common::config_file,
    order   => '10',
    content => template('profile/puppet/agent/puppet.conf.erb'),
  }

  Concat::Fragment <| target == $::profile::puppet::common::config_file |> ~> Service['puppet']
  Concat[$::profile::puppet::common::config_file] ~> Service['puppet']

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
