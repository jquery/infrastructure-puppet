# @summary adds an override for an existing systemd unit
# @param $unit unit to override
# @param $source puppet file source
# @param $content literal contents of the file
# @param $ensure present or absent
define systemd::override (
  String                       $unit,
  Optional[Stdlib::Filesource] $source   = undef,
  Optional[String]             $content  = undef,
  Jqlib::Ensure                $ensure   = present,
) {
  $dir = "/etc/systemd/system/${unit}.d"

  file { $dir:
    ensure => stdlib::ensure($ensure, 'directory'),
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }

  file { "${dir}/${title}.conf":
    ensure  => stdlib::ensure($ensure, 'file'),
    source  => $source,
    content => $content,
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
    notify  => Exec['systemctl daemon-reload'],
  }
}
