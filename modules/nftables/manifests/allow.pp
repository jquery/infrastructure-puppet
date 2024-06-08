# @summary defines nftables rules allowing some kind of traffic
# @param $proto protocol of traffic being allowed, eg. tcp or udp
# @param $dport destination port to allow
# @param $saddr list of source addresses to allow traffic from, or
#   undef to allow traffic from anywhere
define nftables::allow (
  Enum['tcp', 'udp']                   $proto,
  Integer                              $dport,
  Optional[Array[Stdlib::IP::Address]] $saddr = undef,
) {
  if $saddr {
    $saddr_v4 = $saddr.filter |Stdlib::IP::Address $addr| { $addr =~ Stdlib::IP::Address::V4 }
    $saddr_v6 = $saddr.filter |Stdlib::IP::Address $addr| { $addr =~ Stdlib::IP::Address::V6 }

    $per_family_filters = {
      'ip'  => $saddr_v4,
      'ip6' => $saddr_v6,
    }.filter |String[1] $family, Array[Stdlib::IP::Address] $addrs| {
      !$addrs.empty()
    }.map |String[1] $family, Array[Stdlib::IP::Address] $addrs| {
      " ${family} saddr { ${addrs.join(', ')} }"
    }
  } else {
    $per_family_filters = ['']
  }

  $rule = $per_family_filters.reduce('') |String $memo, String $filter| {
    "${memo}add rule inet filter input ${proto} dport ${dport}${filter} ct state new accept\n"
  }

  nftables::conf { $title:
    content => $rule,
  }
}
