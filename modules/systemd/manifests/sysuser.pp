# @summary creates a system user using systemd-sysusers
# @param $source puppet file source
# @param $content literal contents of the file
# @param $ensure present or absent
define systemd::sysuser (
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
  Jqlib::Ensure    $ensure  = present,
) {
  include systemd

  $safe_title = regsubst($title, '[\W_]', '-', 'G')
  file { "/etc/sysusers.d/${safe_title}.conf":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['systemd-sysusers'],
  }
}
