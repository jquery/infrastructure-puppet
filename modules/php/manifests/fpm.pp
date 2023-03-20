# @summary installs a php-fpm service
class php::fpm (
  Hash[String[1], String] $ini_values = {},
) {
  include php

  $version = $::php::version

  ensure_packages([
    "php${version}-fpm",
  ])

  file { "/etc/php/${version}/fpm/pool.d/www.conf":
    ensure  => file,
    content => template('php/fpm/pool.ini.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service["php${version}-fpm"],
    require => Package["php${version}-fpm"],
  }

  service { "php${version}-fpm":
    ensure => running,
    enable => true,
  }
}
