# @summary constructs a ssh authorized_keys from= restriction
#  for connections from this machine.
function ssh::client::from_restriction () >> String[1] {
  $ips = [$facts['networking']['ip'], $facts['networking']['ip6']].filter |$x| {
    # check if we have a routable IPv6 address (and not just a link-local one)
    $x =~ NotUndef and !($x =~ /^fe80/)
  }.sort

  "from=\"${ips.join(',')}\""
}
