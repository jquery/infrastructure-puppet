# @summary run a command as a part of the lets encrypt renewal process
define letsencrypt::hook (
  Jqlib::Ensure                 $ensure   = present,
  Integer[0, 99]                $priority = 50,
  Optional[Stdlib::Filesource]  $source   = undef,
  Optional[String]              $content  = undef,
  Enum['deploy', 'pre', 'post'] $type     = 'post',
) {
  $script = sprintf('%02d-%s', $priority, $title)

  @file { "/etc/letsencrypt/renewal-hooks/${type}/${script}":
    ensure  => $ensure,
    content => $content,
    source  => $source,
    mode    => '0555',
    tag     => 'letsencrypt-hook',
  }
}
