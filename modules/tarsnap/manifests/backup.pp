# @summary backups a specific directory to tarsnap
define tarsnap::backup (
  Array[Stdlib::Unixpath] $paths,
  Jqlib::Ensure           $ensure = present,
) {
  # todo: move to a separate class?
  if !defined(File['/etc/tarsnap.conf']) {
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
  }

  $hour = fqdn_rand(24, "backup-hour-${title}")
  $minute = fqdn_rand(60, "backup-minute-${title}")

  # https://www.tarsnap.com/usage.html
  systemd::timer { "backup-${title}":
    description => "Back up ${title} to Tarsnap",
    user        => 'root',
    command     => "/usr/local/sbin/jq-tarsnap-take-backup ${title} ${paths.join(' ')}",
    interval    => ["OnCalendar=*-*-* ${hour}:${minute}:00"],
    require     => Package['tarsnap'],
  }
}
