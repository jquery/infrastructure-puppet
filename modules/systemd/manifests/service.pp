# @summary a systemd service
define systemd::service (
  Jqlib::Ensure    $ensure  = present,
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
) {
  systemd::unit { "${title}.service":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    notify  => Service[$title],
  }

  service { $title:
    ensure => stdlib::ensure($ensure, 'service'),
    enable => $ensure == 'present',
  }
}
