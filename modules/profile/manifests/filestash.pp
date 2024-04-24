# @summary file stash for constantly updating release files
class profile::filestash (
  String[1]             $certificate = lookup('profile::filestash::certificate'),
  Array[Users::Ssh_key] $deploy_keys = lookup('profile::filestash::deploy_keys', {default_value => []}),
) {
  ensure_packages([
    'rsync',
  ])

  systemd::sysuser { 'filestash':
    content => 'u filestash - "unprivileged user for updating filestash files" /srv/filestash /bin/sh',
  }

  file { [
    '/srv/filestash',
    '/srv/filestash/data',
    '/srv/filestash/data/color',
    '/srv/filestash/data/mobile',
    '/srv/filestash/data/pep',
    '/srv/filestash/data/qunit',
    '/srv/filestash/data/ui',
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
      options => ['restrict', 'command="/usr/bin/rrsync -wo /srv/filestash/data"'],
      require => Systemd::Sysuser['filestash'],
    }
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

  tarsnap::backup { 'filestash':
    paths => ['/srv/filestash/data'],
  }
}
