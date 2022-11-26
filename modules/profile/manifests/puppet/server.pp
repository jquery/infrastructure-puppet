# @summary provisions a puppet server
class profile::puppet::server (
  String $git_repository = lookup('profile::puppet::server::git_repository', {default_value => 'https://github.com/jquery/infrastructure-puppet'}),
  String $git_branch     = lookup('profile::puppet::server::git_branch'),
) {
  systemd::sysuser { 'gitpuppet':
    source => 'puppet:///modules/profile/puppet/server/sysusers.conf',
  }

  $code_dir = '/etc/puppetlabs/code'

  exec { 'remove-old-code-dir':
    command => "/usr/bin/mv ${code_dir} ${code_dir}-old",
    creates => "${code_dir}/old",
  }

  git::clone { 'puppet-code':
    path   => $code_dir,
    remote => $git_repository,
    branch => $git_branch,
    owner  => 'root',
    group  => 'gitpuppet',
    shared => true,
  }

  package { 'puppetserver':
    ensure => installed,
  }

  # TODO: manage config file

  service { 'puppetserver':
    ensure => running,
    enable => true,
  }

  nftables::allow { 'puppetserver':
    proto => 'tcp',
    dport => 8140,
  }
}
