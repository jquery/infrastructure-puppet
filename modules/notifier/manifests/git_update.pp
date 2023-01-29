# @summary configures a node-notifier hook to update a local clone of a git repository
define notifier::git_update (
  String[1]                  $github_repository,
  Array[Notifier::GitTarget] $listen_for,
  Stdlib::Unixpath           $local_path,
  String[1]                  $local_user,
  Array[String[1]]           $extra_commands   = [],
  Array[String[1]]           $restart_services = [],
) {
  file { "/etc/notifier.d/${title}.js":
    ensure  => file,
    content => template('notifier/hook.js.erb'),
    notify  => Service['notifier'],
  }

  file { "/etc/notifier.d/${title}.sh":
    ensure  => file,
    content => template('notifier/git_update/hook.sh.erb'),
    mode    => '0555',
    notify  => Service['notifier'],
  }

  $command_rules = ([
    "/usr/bin/git -C ${local_path} fetch -v origin",
    "/usr/bin/git -C ${local_path} merge --ff-only *"
  ] + $extra_commands).map |String[1] $cmd| {
    "ALL = (${local_user}) NOPASSWD: ${cmd}"
  }

  $restart_rules = $restart_services.map |String[1] $service| {
    "ALL = (root) NOPASSWD: /usr/bin/systemctl restart ${service}"
  }

  sudo::rule { "notifier-${title}":
    target     => 'notifier',
    privileges => $command_rules + $restart_rules,
  }
}
