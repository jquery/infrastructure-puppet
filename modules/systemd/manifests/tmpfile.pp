# @summary adds a systemd-tmpfiles config file
# @param $content the config snippet
# @param $ensure present or absent
define systemd::tmpfile (
  String        $content,
  Jqlib::Ensure $ensure = present,
) {
  $safe_title = regsubst($title, '[\W_/]', '-', 'G')
  $conf_path = "/etc/tmpfiles.d/${safe_title}.conf"

  file { $conf_path:
    ensure  => stdlib::ensure($ensure, 'file'),
    content => $content,
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
    notify  => Exec["tmpfiles-${title}"]
  }

  exec { "tmpfiles-${title}":
    command     => "/usr/bin/systemd-tmpfiles --create --remove ${conf_path}",
    refreshonly => true,
    logoutput   => true,
  }
}
