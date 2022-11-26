# @summary provides the ability to interact with systemd
class systemd () {
  # for systemd-sysusers
  file { '/etc/sysusers.d':
    ensure  => directory,
    purge   => true,
    recurse => true,
  }
  service { 'systemd-sysusers': }
}
