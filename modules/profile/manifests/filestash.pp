# @summary file stash for constantly updating release files
class profile::filestash (
  String[1] $certificate = lookup('profile::filestash::certificate'),
) {
  systemd::sysuser { 'filestash':
    content => 'u filestash - "unprivileged user for updating filestash files" /srv/filestash',
  }

  file { '/srv/filestash':
    ensure  => directory,
    owner   => 'filestash',
    group   => 'filestash',
    mode    => '0775',
    require => Systemd::Sysuser['filestash'],
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
