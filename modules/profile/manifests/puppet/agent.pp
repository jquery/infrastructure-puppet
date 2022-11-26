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
}
