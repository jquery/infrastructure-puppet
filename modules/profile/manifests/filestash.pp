# @summary file stash for constantly updating release files
class profile::filestash (
  String[1]             $certificate = lookup('profile::filestash::certificate'),
  Array[Users::Ssh_key] $deploy_keys = lookup('profile::filestash::deploy_keys', {default_value => []}),
) {
  systemd::sysuser { 'filestash':
    content => 'u filestash - "unprivileged user for updating filestash files" /srv/filestash',
  }

  file { [
    '/srv/filestash',
    '/srv/filestash/data'
  ]:
    ensure  => directory,
    owner   => 'filestash',
    group   => 'filestash',
    mode    => '0775',
    require => Systemd::Sysuser['filestash'],
  }

  $deploy_keys.each |Integer $i, Users::Ssh_key $key| {
    ssh_authorized_key { "filestash_${i}":
      user    => 'filestash',
      type    => $key['type'],
      key     => $key['key'],
      require => Systemd::Sysuser['filestash'],
    }
  }

  ssh::server::config { 'filestash':
    source => 'puppet:///modules/profile/filestash/sshd.conf',
  }

  $tls_config = nginx::tls_config()

  nginx::site { $::facts['networking']['fqdn']:
    content => template('profile/filestash/vhost.nginx.erb'),
    require => [
      File['/srv/filestash'],
      Letsencrypt::Certificate[$certificate],
    ],
  }

  nftables::allow { 'filestash-https':
    proto => 'tcp',
    dport => 443,
  }
}
