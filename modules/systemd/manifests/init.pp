# @summary provides the ability to interact with systemd
class systemd () {
  include systemd

  exec { 'systemctl daemon-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  # for systemd-sysusers
  file { '/etc/sysusers.d':
    ensure  => directory,
    purge   => true,
    recurse => true,
  }
  service { 'systemd-sysusers': }
}
