# @summary installs a php-fpm service
class php::fpm () {
  include php

  $version = $::php::version

  ensure_packages([
    "php${version}",
    "php${version}-fpm",
  ])

  service { "php${version}-fpm":
    ensure => running,
    enable => true,
  }
}
