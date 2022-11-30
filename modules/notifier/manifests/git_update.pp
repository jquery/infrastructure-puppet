# @summary configures a node-notifier hook to update a local clone of a git repository
define notifier::git_update (
  String[1]                  $github_repository,
  Array[Notifier::GitTarget] $listen_for,
  Stdlib::Unixpath           $local_path,
  String[1]                  $local_user,
  Boolean                    $submodules = false,
) {
  file { "/etc/notifier.d/${title}.js":
    ensure  => file,
    content => template('notifier/git_update/hook.js.erb'),
    notify  => Service['notifier'],
  }

  file { "/etc/notifier.d/${title}.sh":
    ensure  => file,
    content => template('notifier/git_update/hook.sh.erb'),
    mode    => '0555',
    notify  => Service['notifier'],
  }

  sudo::rule { "notifier-${title}":
    target     => 'notifier',
    privileges => [
      "ALL = (${local_user}) NOPASSWD: /usr/bin/git -C ${local_path} fetch -v origin",
      "ALL = (${local_user}) NOPASSWD: /usr/bin/git -C ${local_path} merge --ff-only *",
      "ALL = (${local_user}) NOPASSWD: /usr/bin/git -C ${local_path} submodule update --init --recursive",
    ],
  }
}
