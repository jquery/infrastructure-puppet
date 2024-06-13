# @summary provisions a puppet server
class profile::puppet::server (
  String[1]     $java_memory            = lookup('profile::puppet::server::java_memory', {default_value => '1g'}),
  String[1]     $g10k_branch_filter     = lookup('profile::puppet::server::g10k_branch_filter'),
  String[1]     $nginx_certificate_name = lookup('profile::puppet::server::nginx_certificate_name'),
  Stdlib::Email $tarsnap_account_email  = lookup('profile::puppet::server::tarsnap_account_email'),
) {
  include profile::puppet::common

  stdlib::ensure_packages([
    'rsync',
  ])

  $primary_host = $profile::puppet::agent::ca_server
  $is_primary = $primary_host == $facts['networking']['fqdn']

  $termini_package = debian::codename() ? {
    'bullseye' => 'puppetdb-termini',
    default    => 'puppet-terminus-puppetdb',
  }

  $server_config_path = debian::codename() ? {
    'bullseye' => '/etc/puppetlabs/puppetserver',
    default    => '/etc/puppet/puppetserver',
  }

  $server_var_dir = debian::codename() ? {
    'bullseye' => '/opt/puppetlabs/server/data/puppetserver',
    default    => '/var/lib/puppetserver',
  }

  $server_run_dir = debian::codename() ? {
    'bullseye' => '/var/run/puppetlabs/puppetserver',
    default    => '/run/puppetserver',
  }

  $server_log_dir = debian::codename() ? {
    'bullseye' => '/var/log/puppetlabs/puppetserver',
    default    => '/var/log/puppetserver',
  }

  $code_path = debian::codename() ? {
    'bullseye' => '/etc/puppetlabs/code',
    default    => '/etc/puppet/code',
  }

  $g10k_config_path = debian::codename() ? {
    'bullseye' => '/etc/puppetlabs/g10k.yaml',
    default    => '/etc/puppet/g10k.yaml',
  }

  package { [
    'puppetserver',
    $termini_package,
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
    command => "/usr/bin/mv ${code_path} ${code_path}-old",
    creates => "${code_path}-old",
  }

  file { $code_path:
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

  $g10k_deploy_base_path = "${code_path}/environments"
  $private_repo_dir = '/srv/git/puppet/private'

  file { $g10k_config_path:
    ensure  => file,
    content => template('profile/puppet/server/g10k.yaml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Exec['g10k'],
  }

  exec { 'g10k':
    command     => "/usr/bin/g10k -config ${g10k_config_path}",
    user        => 'gitpuppet',
    refreshonly => true,
    logoutput   => true,
    require     => File[$code_path],
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
    require => Package['git'],
  }

  file { [
    "${private_repo_dir}/hieradata/",
    "${private_repo_dir}/files/",
  ]:
    ensure  => directory,
    owner   => 'gitpuppet',
    group   => 'gitpuppet',
    mode    => '2775',
    require => Exec['git-init-puppet-private'],
  }

  file { [
    '/etc/puppetlabs/hieradata',
    '/etc/puppet/hieradata'
  ]:
    ensure  => absent,
    recurse => true,
    force   => true,
    purge   => true,
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

  ['auth.conf', 'puppetserver.conf'].each |String $file| {
    $puppet_agent_base_path = $profile::puppet::common::config_path
    file { "${server_config_path}/conf.d/${file}":
      ensure  => file,
      mode    => '0440',
      group   => 'puppet',
      content => template("profile/puppet/server/config/${file}.erb"),
      notify  => Service['puppetserver'],
    }
  }

  file { "${profile::puppet::common::config_path}/routes.yaml":
    ensure  => file,
    mode    => '0444',
    content => template('profile/puppet/server/routes.yaml.erb'),
    notify  => Service['puppetserver'],
  }

  $puppetservers = jqlib::resource_hosts('class', 'profile::puppet::server')
  $puppetservers_notself = $puppetservers.filter |Stdlib::Fqdn $it| { $it != $facts['networking']['fqdn'] }

  file { "${profile::puppet::common::config_path}/puppetdb.conf":
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

  # Avoid running out of disk space (daily)
  systemd::timer { 'puppet_report_cleanup':
    ensure      => present,
    description => 'Remove old puppet reports',
    user        => 'root',
    command     => "find ${server_var_dir}/reports/ -type f -name '*.yaml' -mtime +21 -exec rm -f {} \;",
    interval    => ['OnCalendar=*-*-* 12:00:00'],
  }

  nftables::allow { 'puppetserver':
    proto => 'tcp',
    dport => 8140,
  }

  notifier::run_command { 'puppet-public':
    github_repository => 'jquery/infrastructure-puppet',
    listen_for        => [{ branch => 'staging' }, { branch => 'production' }],
    source            => 'puppet:///modules/profile/puppet/server/puppet-merge.sh',
  }

  sudo::rule { 'notifier-g10k':
    target     => 'notifier',
    privileges => [
      "ALL = (gitpuppet) NOPASSWD: /usr/bin/g10k -config ${g10k_config_path}",
    ],
  }

  git::config { '/etc/gitconfig':
    settings => {
      'safe' => {
        'directory' => $private_repo_dir,
      },
    },
  }

  class { 'tarsnap::keymgmt':
    base_path     => "${private_repo_dir}/files/tarsnap-keys",
    account_email => $tarsnap_account_email,
    user          => 'gitpuppet',
    group         => 'gitpuppet',
  }

  tarsnap::backup { 'puppet-private':
    paths => [$private_repo_dir],
  }

  # This also uses config from tarsnap::keymgmt.
  file { '/usr/local/bin/jq-decom-instance':
    ensure => file,
    source => 'puppet:///modules/profile/puppet/server/jq-decom-instance.sh',
    owner  => 'root',
    group  => 'gitpuppet',
    mode   => '0550',
  }

  include profile::ssh::ca

  ssh::client::user_key { 'puppet-sync': }

  if $facts['ssh_local_keys'] and $facts['ssh_local_keys']['puppet-sync'] {
    $key = $facts['ssh_local_keys']['puppet-sync']
    @@ssh_authorized_key { "puppet-sync-${facts['networking']['fqdn']}":
      user    => 'root',
      type    => $key.split(' ')[0],
      key     => $key.split(' ')[1],
      options => ['restrict', ssh::client::from_restriction()],
      tag     => 'profile::puppet::server::puppet_sync',
    }
  }

  Ssh_authorized_key <<| tag == 'profile::puppet::server::puppet_sync' |>>

  systemd::timer { 'pull-puppet-ca':
    ensure      => $is_primary.bool2str('absent', 'present'),
    user        => 'root',
    description => 'rsync Puppet CA files from the primary server',
    # TODO: stop hardcoding path once fully on Debian 12
    command     => "/usr/bin/rsync -avp --delete --chown puppet:puppet -e \"/usr/bin/ssh -i /etc/ssh/local_keys.d/puppet-sync\" ${primary_host}:/etc/puppet/puppetserver/ca/ ${server_config_path}/ca/",
    interval    => ['OnCalendar=*-*-* *:4/5:00'],
  }

  systemd::timer { 'pull-puppet-private':
    ensure      => $is_primary.bool2str('absent', 'present'),
    user        => 'root',
    description => 'rsync Puppet private repository from the primary server',
    command     => "/usr/bin/rsync -avp --delete --chown gitpuppet:gitpuppet -e \"/usr/bin/ssh -i /etc/ssh/local_keys.d/puppet-sync\" ${primary_host}:${private_repo_dir}/ ${private_repo_dir}/",
    interval    => ['OnCalendar=*-*-* *:2/5:00'],
  }

  # Expose SSH keys so users can verify them
  file { '/srv/www':
    ensure => directory,
  }

  $ca_data = jqlib::secret('ssh_ca/ca.pub')
  $keys = jqlib::puppetdb_query('resources[certname, parameters] { type = "Sshkey" and exported = true }').map |$key| {
    $names = [$key['certname']] + $key['parameters']['host_aliases']
    "${names.sort.join(',')} ${key['parameters']['type']} ${key['parameters']['key']}"
  }.sort

  file { '/srv/www/known_hosts':
    ensure    => file,
    content   => template('profile/puppet/server/web/known_hosts.erb'),
    show_diff => false,
  }

  $tls_config = nginx::tls_config()
  nginx::site { 'puppet-metadata':
    content => template('profile/puppet/server/web/site.nginx.erb'),
    require => Letsencrypt::Certificate[$nginx_certificate_name],
  }

  nftables::allow { 'puppet-metadata':
    proto => 'tcp',
    dport => 443,
  }
}
