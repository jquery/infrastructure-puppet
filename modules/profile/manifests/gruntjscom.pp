# @summary configures node-notifier and exposes it via tls
class profile::gruntjscom (
  String[1]           $tls_key_name   = lookup('profile::gruntjscom::tls_key_name'),
  Stdlib::Fqdn        $canonical_name = lookup('profile::gruntjscom::canonical_name'),
  Array[Stdlib::Fqdn] $aliases        = lookup('profile::gruntjscom::aliases'),
  Boolean             $robots_deny    = lookup('profile::gruntjscom::robots_deny', {default_value => false}),
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
    command => '/usr/bin/npm install --cache /tmp/npm-gruntjscom',
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
    # also executes grunt
    extra_commands    => ["/usr/bin/npm install --prefix ${base_path} --cache /tmp/npm-gruntjscom"],
    restart_services  => ['gruntjscom.service'],
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

  if $robots_deny {
    file { '/srv/gruntjscom-robots':
      ensure => directory,
      owner  => 'www-data',
      group  => 'www-data',
    }
    file { '/srv/gruntjscom-robots/robots.txt':
      ensure  => file,
      owner   => 'www-data',
      group   => 'www-data',
      content => "User-Agent: *\nDisallow: /\n",
    }
  }
}
