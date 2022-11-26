# @summary provisions a puppet server
class profile::puppet::server (
  String $git_repository = lookup('profile::puppet::server::git_repository', {default_value => 'https://github.com/jquery/infrastructure-puppet'}),
  String $git_branch     = lookup('profile::puppet::server::git_branch'),
) {
  # TODO: manage the apt repository

  systemd::sysuser { 'gitpuppet':
    source => 'puppet:///modules/profile/puppet/server/sysusers.conf',
  }

  $code_dir = '/etc/puppetlabs/code'

  exec { 'remove-old-code-dir':
    command => "/usr/bin/mv ${code_dir} ${code_dir}-old",
    creates => "${code_dir}-old",
  }

  git::clone { 'puppet-code':
    path   => $code_dir,
    remote => $git_repository,
    branch => $git_branch,
    owner  => 'root',
    group  => 'gitpuppet',
    shared => true,
  }

  file { '/usr/local/bin/puppet-merge':
    ensure => file,
    source => 'puppet:///modules/profile/puppet/server/puppet-merge.sh',
    owner  => 'root',
    group  => 'gitpuppet',
    mode   => '0554',
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
