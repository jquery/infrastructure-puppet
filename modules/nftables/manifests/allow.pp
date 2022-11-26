# @summary defines nftables rules allowing some kind of traffic
# @param $proto protocol of traffic being allowed, eg. tcp or udp
# @param $dport destination port to allow
define nftables::allow (
  Enum['tcp', 'udp'] $proto,
  Integer            $dport,
) {
  nftables::conf { $title:
    content => "add rule inet filter input ${proto} dport ${dport} ct state new accept\n",
  }
}
