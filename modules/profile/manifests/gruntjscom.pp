# @summary configures node-notifier and exposes it via tls
class profile::gruntjscom (
  String[1] $tls_key_name   = lookup('profile::gruntjscom::tls_key_name'),
) {
  ensure_packages(['nodejs', 'npm'])

  $backend_port = 5678
  $base_path = '/srv/gruntjscom'

  git::clone { 'gruntjscom':
    path   => $base_path,
    remote => 'https://github.com/gruntjs/gruntjs.com',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  exec { 'gruntjscom-npm-install':
    command => '/usr/bin/npm install --production --cache /tmp/npm-gruntjscom',
    cwd     => $base_path,
    creates => "${base_path}/node_modules",
    user    => 'www-data',
    require => Git::Clone['gruntjscom'],
  }

  systemd::service { 'gruntjscom':
    content => template('profile/gruntjscom/gruntjscom.service.erb'),
  }

  notifier::git_update { 'gruntjscom':
    github_repository => 'gruntjs/gruntjs.com',
    listen_for        => [{ branch => 'main' }],
    local_path        => $base_path,
    local_user        => 'www-data',
  }

  nftables::allow { 'gruntjscom-https':
    proto => 'tcp',
    dport => 443,
  }

  $tls_config = nginx::tls_config()

  nginx::site { 'gruntjscom':
    content => template('profile/gruntjscom/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }
}
