# @summary nftables config snippet
define nftables::conf (
  Optional[Stdlib::Filesource] $source   = undef,
  Optional[String]             $content  = undef,
  Jqlib::Ensure                $ensure   = present,
  Integer[0, 99]               $priority = 50,
) {
  $safe_name = regsubst($title, '[\W_]', '-', 'G')
  $file_name = sprintf('%02d-%s.nft', $priority, $safe_name)

  @file { "/etc/nftables/${file_name}":
    ensure  => stdlib::ensure($ensure, 'file'),
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    source  => $source,
    content => $content,
    notify  => Service['nftables'],
    tag     => 'nftables',
  }
}
