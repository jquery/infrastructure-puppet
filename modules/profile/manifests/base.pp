# @summary configures the base system for all nodes
class profile::base () {
  include jquery::base
  include profile::puppet::agent

  class { 'ssh::server': }
}
