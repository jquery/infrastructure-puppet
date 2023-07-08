# @summary installs a git config file somewhere
define git::config (
  Hash[String, Hash[String, Variant[String, Array[String]]]] $settings,
) {
  file { $title:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('git/gitconfig.erb'),
  }
}
