# @summary Simple systemd timer
define systemd::timer (
  String[1]                            $description,
  String[1]                            $user,
  Variant[String[1], Array[String[1]]] $command,
  Array[String[1]]                     $interval,
  Array[String[1]]                     $environment = [],
  Jqlib::Ensure                        $ensure      = present,
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
    ensure => stdlib::ensure($ensure, 'service'),
    enable => $ensure == 'present',
  }
}
