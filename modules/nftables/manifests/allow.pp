# @summary defines nftables rules allowing some kind of traffic
# @summary $proto protocol of traffic being allowed, eg. tcp or udp
# @summary $dport destination port to allow, if the protocol supports them
define nftables::allow (
  String            $proto,
  Optional[Integer] $dport = undef,
) {
  if $dport == undef {
    $rule_dport = ''
  } else {
    $rule_dport = "dport ${dport}"
  }

  nftables::conf { $title:
    content => template('nftables/allow.nft.erb'),
  }
}
