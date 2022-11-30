# @summary configures a node-notifier hook to run an arbitrary command
define notifier::run_command (
  String[1]                    $github_repository,
  Array[Notifier::GitTarget]   $listen_for,
  Optional[Stdlib::Filesource] $source   = undef,
  Optional[String]             $content  = undef,
) {
  file { "/etc/notifier.d/${title}.js":
    ensure  => file,
    content => template('notifier/hook.js.erb'),
    notify  => Service['notifier'],
  }

  file { "/etc/notifier.d/${title}.sh":
    ensure  => file,
    content => $content,
    source  => $source,
    mode    => '0555',
    notify  => Service['notifier'],
  }
}
