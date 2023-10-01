# @summary configures node-notifier to receive github webhooks
# @param $webhook_secret github webhook secret
# @param $version git tag to clone
class notifier (
  String[1] $webhook_secret,
  String[1] $version,
) {
  ensure_packages(['nodejs', 'npm'])

  $base_path = '/usr/local/share/notifier'

  systemd::sysuser { 'notifier':
    content => 'u notifier 601 "node-notifier server" /var/cache/notifier',
  }

  # needed for npm caching :(
  systemd::tmpfile { 'notifier':
    content => 'd /var/cache/notifier 0770 notifier notifier',
    require => Systemd::Sysuser['notifier'],
  }

  git::clone { 'notifier':
    remote  => 'https://github.com/jquery/node-notifier-server',
    path    => $base_path,
    owner   => 'notifier',
    group   => 'notifier',
    branch  => $version,
    # After updates, git::clone will delete old node_modules, allowing
    # the next exec to install the new version, and then restart the service.
    update  => true,
    require => Systemd::Tmpfile['notifier'],
  }

  exec { 'notifier-npm-install':
    command => '/usr/bin/npm install --production',
    cwd     => $base_path,
    creates => "${base_path}/node_modules",
    user    => 'notifier',
    require => [
      Git::Clone['notifier'],
      Systemd::Tmpfile['notifier'],
    ],
    notify  => Service['notifier'],
  }

  $config = {
    'webhookSecret' => $webhook_secret,
  }

  file { "${base_path}/config.json":
    ensure  => 'file',
    content => $config.to_json,
    owner   => 'root',
    group   => 'notifier',
    mode    => '0440',
    require => Git::Clone['notifier'],
    notify  => Service['notifier'],
  }

  file { '/etc/notifier.d/':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['notifier'],
  }

  systemd::service { 'notifier':
    content => template('notifier/notifier.service.erb'),
  }
}
