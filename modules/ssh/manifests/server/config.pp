# @summary configures an extra ssh server config file
define ssh::server::config (
  Optional[Stdlib::Filesource] $source   = undef,
  Optional[String]             $content  = undef,
  Jqlib::Ensure                $ensure   = present,
  Integer[0, 99]               $priority = 50,
) {
  $safe_name = regsubst($title, '[\W_]', '-', 'G')
  $file_name = sprintf('%02d-%s.conf', $priority, $safe_name)

  file { "/etc/ssh/sshd_config.d/${file_name}":
    ensure  => stdlib::ensure($ensure, 'file'),
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    source  => $source,
    content => $content,
    notify  => Service['sshd'],
  }
}
