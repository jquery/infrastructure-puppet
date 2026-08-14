# @summary installs a php-fpm service
#
# NOTE: Directives with INI_SYSTEM scope, such as opcache.memory_consumption,
# can only be set via $config_php in php.ini.
# See https://www.php.net/manual/en/ini.list.php for which directives have this scope.
# If set wrong these can cause silent chaos (https://github.com/jquery/infrastructure-puppet/issues/109).
#
# Use `config_php` (php.ini) for INI_SYSTEM settings that must be set there to work.
# You can also set non-INI_SYSTEM settings there that are shared among multiple pools.
# In that case they act similar to config_pool_user (php_value) and are still allowed
# to be overriden at runtime PHP via `ini_set()`.
#
# Use `config_pool_admin` (php_admin_value) for fixed settings that runtime PHP code
# may not change via `ini_set()`.
#
# Use `config_pool_user` (php_value) for defaults that runtime PHP code
# is allowed to change via `ini_set()`.
#
# @param $config_php System settings for php.ini in /etc/php/_/fpm/conf.d/
# @param $config_pool_admin Admin settings via php_admin_value in /etc/php/_/fpm/pool.d/www.conf
# @param $config_pool_user User settings via php_value in /etc/php/_/fpm/pool.d/www.conf
class php::fpm (
  Hash[String[1], String] $config_php = {},
  Hash[String[1], String] $config_pool_admin = {},
  Hash[String[1], String] $config_pool_user = {},
) {
  include php

  $version = $::php::version

  $config_php_merged = merge({
    # Enable deprecation warnings
    # Will be redundant on PHP 8.0+
    # https://www.php.net/manual/en/errorfunc.configuration.php#ini.error-reporting
    'error_reporting' => 'E_ALL',
  }, $config_php)

  $config_pool_admin_merged = merge({
    'expose_php'      => 'On',
  }, $config_pool_admin)

  $config_pool_user_merged = merge({
  }, $config_pool_user)

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

  file { "/etc/php/${version}/fpm/conf.d/50-custom.ini":
    ensure  => file,
    content => template('php/fpm/custom.ini.erb'),
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
