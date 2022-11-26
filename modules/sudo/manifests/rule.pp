# @summary manages a sudo rule in sudoers.d
# @param $privileges list of sudo privs
# @param $target either a user name or a group name with a % prefix
# @param $ensure present or absent
define sudo::rule (
  Array[String] $privileges,
  String        $target,
  Jqlib::Ensure $ensure     = present,
) {
  $title_safe = regsubst($title, '\W', '-', 'G')
  $filename = "/etc/sudoers.d/${title_safe}"

  if $ensure == 'present' {
    file { $filename:
      ensure       => file,
      owner        => 'root',
      group        => 'root',
      mode         => '0440',
      content      => template('sudo/rule.erb'),
      validate_cmd => '/usr/sbin/visudo -cqf %',
    }
  } else {
    file { $filename:
      ensure => absent,
    }
  }
}
