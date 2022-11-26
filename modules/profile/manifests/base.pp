# @summary configures the base system for all nodes
class profile::base () {
  include profile::base::apt
  include profile::base::digitalocean
  include profile::puppet::agent

  class { 'nftables': }
  class { 'ssh::server': }
  class { 'users': }

  # useful packages to install everywhere
  ensure_packages([
    'curl',
    'git',
    'jq',
    'tmux',
  ])
}
