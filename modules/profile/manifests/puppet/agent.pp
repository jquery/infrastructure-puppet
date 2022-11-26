# @summary configures the puppet agent
class profile::puppet::agent () {
  # TODO: manage the apt repository

  package { 'puppet-agent':
    ensure => installed,
  }

  # TODO: manage config file

  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
