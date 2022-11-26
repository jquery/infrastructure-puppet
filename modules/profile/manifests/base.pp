# @summary configures the base system for all nodes
# @param $accounts all user account data
# @param $groups all group data
# @param $enabled_groups groups enabled on this host
class profile::base (
  Hash[String, Hash] $accounts       = lookup('profile::base::accounts'),
  Array[String]      $enabled_groups = lookup('profile::base::enabled_groups', {default_value => []}),
  Hash[String, Hash] $groups         = lookup('profile::base::groups'),
) {
  include profile::base::apt
  include profile::base::digitalocean
  include profile::puppet::agent

  class { 'nftables': }
  class { 'ssh::server': }
  class { 'sudo': }

  class { 'users':
    accounts       => $accounts,
    groups         => $groups,
    enabled_groups => $enabled_groups + ['sudo'],
  }

  # useful packages to install everywhere
  ensure_packages([
    'curl',
    'git',
    'jq',
    'tmux',
  ])
}
