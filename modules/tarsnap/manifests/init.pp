# @summary installs the tarsnap backup client
class tarsnap () {
  file { '/usr/share/keyrings/tarsnap-archive-keyring.asc':
    ensure  => file,
    source  => 'puppet:///modules/tarsnap/tarsnap-archive-keyring.asc',
    # let the tarsnap-archive-keyring package take over once installed
    replace => false,
  }

  apt::source { 'tarsnap':
    location => "http://pkg.tarsnap.com/deb/${debian::codename()}",
    release  => '',
    repos    => './',
    keyring  => '/usr/share/keyrings/tarsnap-archive-keyring.asc',
    pin      => 150,
  }

  ensure_packages([
    'tarsnap',
    'tarsnap-archive-keyring'
  ], {
    require => Class['Apt::Update'],
  })

  systemd::sysuser { 'tarsnap':
    content => 'u tarsnap 602 "unprivileged user for taking backups" /var/lib/backup',
  }

  file { '/var/lib/backup':
    ensure  => directory,
    owner   => 'tarsnap',
    group   => 'tarsnap',
    mode    => '0755',
    require => [Systemd::Sysuser['tarsnap'], Service['systemd-sysusers']],
  }

  file { '/etc/tarsnap.conf':
    ensure => file,
    source => 'puppet:///modules/tarsnap/backup/tarsnap.conf',
  }

  file { '/etc/tarsnap.key':
    ensure    => file,
    content   => jqlib::secret("tarsnap-keys/${::fqdn}.key"),
    owner     => 'root',
    group     => 'root',
    mode      => '0440',
    show_diff => false,
  }

  file { '/usr/local/sbin/jq-tarsnap-take-backup':
    ensure => file,
    source => 'puppet:///modules/tarsnap/backup/jq-tarsnap-take-backup.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0554',
  }

  Systemd::Timer <| tag == 'tarsnap::backup' |>
}
