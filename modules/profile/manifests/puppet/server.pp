# @summary provisions a puppet server
class profile::puppet::server (
  String $git_repository = lookup('profile::puppet::server::git_repository', {default_value => 'https://github.com/jquery/infrastructure-puppet'}),
  String $git_branch     = lookup('profile::puppet::server::git_branch'),
  String $java_memory    = lookup('profile::puppet::server::java_memory', {default_value => '1g'}),
) {
  include profile::puppet::common

  package { [
    'puppetserver',
    'puppetdb-termini',
    'g10k',

    # for the htpasswd tool
    'apache2-utils',
  ]:
    ensure => installed,
  }

  systemd::sysuser { 'gitpuppet':
    source => 'puppet:///modules/profile/puppet/server/sysusers.conf',
  }

  exec { 'remove-old-code-dir':
    command => '/usr/bin/mv /etc/puppetlabs/code /etc/puppetlabs/code-old',
    creates => '/etc/puppetlabs/code-old',
  }

  file { '/etc/puppetlabs/code':
    ensure  => directory,
    owner   => 'gitpuppet',
    group   => 'gitpuppet',
    require => Exec['remove-old-code-dir'],
  }

  file { [
    '/srv/git',
    '/srv/git/puppet',
  ]:
    ensure => directory,
  }

  $g10k_deploy_base_path = '/etc/puppetlabs/code/environments'
  $code_dir = '/srv/git/puppet/public'
  $private_repo_dir = '/srv/git/puppet/private'

  file { '/etc/puppetlabs/g10k.yaml':
    ensure  => file,
    content => template('profile/puppet/server/g10k.yaml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Exec['g10k'],
  }

  exec { 'g10k':
    command     => '/usr/bin/g10k -config /etc/puppetlabs/g10k.yaml',
    user        => 'gitpuppet',
    refreshonly => true,
    logoutput   => true,
    require     => File['/etc/puppetlabs/code'],
  }

  git::clone { 'puppet-code':
    path   => $code_dir,
    remote => $git_repository,
    branch => $git_branch,
    owner  => 'gitpuppet',
    group  => 'gitpuppet',
    shared => true,
  }

  exec { 'g10k-initial':
    command => '/usr/bin/g10k -puppetfile',
    user    => 'gitpuppet',
    cwd     => $code_dir,
    creates => "${code_dir}/vendor_modules",
  }

  file { '/usr/local/bin/puppet-merge':
    ensure => file,
    source => 'puppet:///modules/profile/puppet/server/puppet-merge.sh',
    owner  => 'root',
    group  => 'gitpuppet',
    mode   => '0554',
  }

  file { $private_repo_dir:
    ensure => directory,
    owner  => 'gitpuppet',
    group  => 'gitpuppet',
    mode   => '2775',
  }
  exec { 'git-init-puppet-private':
    command => "/usr/bin/git -c core.sharedRepository=group init ${private_repo_dir}",
    creates => "${private_repo_dir}/.git",
    user    => 'gitpuppet',
    group   => 'gitpuppet',
    umask   => '002',
  }

  file { '/etc/puppetlabs/hieradata':
    ensure => directory,
  }

  file { '/etc/puppetlabs/hieradata/public':
    ensure => link,
    target => "${code_dir}/hieradata",
  }

  file { '/etc/puppetlabs/hieradata/private':
    ensure => link,
    target => "${private_repo_dir}/hieradata",
  }

  systemd::tmpfile { 'g10k-cache':
    content => 'd /tmp/g10k 2775 gitpuppet gitpuppet',
  }

  concat::fragment { 'puppet-config-server':
    target  => $::profile::puppet::common::config_file,
    order   => '20',
    content => template('profile/puppet/server/puppet.conf.erb'),
  }

  Concat::Fragment <| target == $::profile::puppet::common::config_file |> ~> Service['puppetserver']
  Concat[$::profile::puppet::common::config_file] ~> Service['puppetserver']

  ['puppetserver.conf'].each |String $file| {
    file { "/etc/puppetlabs/puppetserver/conf.d/${file}":
      ensure  => file,
      mode    => '0440',
      group   => 'puppet',
      content => template("profile/puppet/server/config/${file}.erb"),
      notify  => Service['puppetserver'],
    }
  }

  file { '/etc/puppetlabs/puppet/routes.yaml':
    ensure  => file,
    mode    => '0444',
    content => template('profile/puppet/server/routes.yaml.erb'),
    notify  => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/puppetdb.conf':
    ensure  => file,
    mode    => '0444',
    content => template('profile/puppet/server/puppetdb.conf.erb'),
    notify  => Service['puppetserver'],
  }

  file { '/etc/default/puppetserver':
    ensure  => file,
    mode    => '0444',
    content => template('profile/puppet/server/default.erb'),
    notify  => Service['puppetserver'],
  }

  service { 'puppetserver':
    ensure => running,
    enable => true,
  }

  nftables::allow { 'puppetserver':
    proto => 'tcp',
    dport => 8140,
  }
}
