# @summary backups a specific directory to tarsnap
define tarsnap::backup (
  Array[Stdlib::Unixpath] $paths,
  Optional[String[1]]     $take_backup_command = undef,
  Jqlib::Ensure           $ensure              = present,
) {
  $hour = fqdn_rand(24, "backup-hour-${title}")
  $minute = fqdn_rand(60, "backup-minute-${title}")

  $commands = [
    $take_backup_command,
    "/usr/local/sbin/jq-tarsnap-take-backup ${title} ${paths.join(' ')}"
  ].filter |$it| { $it != undef }

  @systemd::timer { "backup-${title}":
    description => "Back up ${title} to Tarsnap",
    user        => 'root',
    command     => $commands,
    interval    => ["OnCalendar=*-*-* ${hour}:${minute}:00"],
    require     => Package['tarsnap'],
    tag         => 'tarsnap::backup',
  }
}
