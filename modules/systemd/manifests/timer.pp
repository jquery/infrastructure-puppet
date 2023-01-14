# @summary Simple systemd timer
define systemd::timer (
  String        $description,
  String        $user,
  String        $command,
  Array[String] $interval,
  Array[String] $environment = [],
  Jqlib::Ensure $ensure      = present,
) {
  systemd::unit { "${title}.service":
    ensure  => $ensure,
    content => template('systemd/timer/service.erb'),
    notify  => Service["${title}.timer"],
  }

  systemd::unit { "${title}.timer":
    ensure  => $ensure,
    content => template('systemd/timer/timer.erb'),
    notify  => Service["${title}.timer"],
  }

  service { "${title}.timer":
    ensure   => stdlib::ensure($ensure, 'service'),
    enable   => $ensure == 'present',
  }
}
