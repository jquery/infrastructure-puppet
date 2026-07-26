# @summary creates a system user using systemd-sysusers
# @param $source puppet file source
# @param $content literal contents of the file
# @param $ensure present or absent
define systemd::sysuser (
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
  Jqlib::Ensure    $ensure  = present,
) {
  include systemd

  $safe_title = regsubst($title, '[\W_]', '-', 'G')
  $sysusers_file = "/etc/sysusers.d/${safe_title}.conf"
  file { $sysusers_file:
    ensure  => stdlib::ensure($ensure, 'file'),
    source  => $source,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['systemd-sysusers'],
  }

  # Debian 11 Bullseye seems to monitor /etc/sysusers.d/ and do this automatically.
  # Debian 12 Bookworm and later require a call to systemd-sysusers.
  # https://github.com/jquery/infrastructure-puppet/issues/91
  if debian::codename() != 'bullseye' {
    if $ensure != 'absent' {
      exec { "update-sysusers-${title}":
          command  => "/bin/systemd-sysusers ${sysusers_file}",
          path     => '/usr/bin:/usr/sbin:/bin',
          provider => 'shell',
          onlyif   => "test -n \"\$(systemd-sysusers --dry-run ${sysusers_file} 2>&1)\"",
          user     => 'root',
      }
    }
  }
}
