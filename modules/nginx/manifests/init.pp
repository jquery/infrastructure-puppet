# == Class: nginx
#
# This module provides an 'nginx::site' resource type that takes an Nginx
# configuration file as input. The base class installs the Nginx package,
# and sets up a status site at localhost:8080.
#
class nginx {
  package { 'nginx-full':
    ensure => present,
  }

  service { 'nginx':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    =>  Package['nginx-full'],
  }

  exec { 'nginx-reload':
    command     => '/usr/sbin/service nginx reload',
    refreshonly => true,
    require     =>  Package['nginx-full'],
  }

  file { [ '/etc/nginx/conf.d', '/etc/nginx/sites-available', '/etc/nginx/sites-enabled' ]:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nginx-full'],
  }

  file { '/etc/nginx/sites-available/00-status':
    source => 'puppet:///modules/nginx/status.nginx',
    notify => Exec['nginx-reload'],
  }

  file { '/etc/nginx/sites-enabled/00-status':
    ensure => 'link',
    target => '/etc/nginx/sites-available/00-status',
    notify => Exec['nginx-reload'],
  }
}
