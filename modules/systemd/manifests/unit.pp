# @summary a systemd unit file
define systemd::unit (
  Jqlib::Ensure    $ensure  = present,
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
) {
  include systemd

  file { "/etc/systemd/system/${title}":
    ensure  => $ensure,
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
    source  => $source,
    content => $content,
    notify  => Exec['systemctl daemon-reload'],
  }
}
