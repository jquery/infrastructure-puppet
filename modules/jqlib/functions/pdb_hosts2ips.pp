# @summary converts a list of hostnames to list of IPs according to puppetdb data
function jqlib::pdb_hosts2ips (
  Array[Stdlib::Fqdn] $hosts,
) >> Array[Stdlib::IP::Address::Nosubnet] {
  $certname_filter = $hosts
    .map |Stdlib::Fqdn $host| { "certname = '${host}'" }
    .join(' or ')

  $pql = @("PQL")
  facts[value] {
    name = 'networking'
    and (${certname_filter})
  }
  | PQL

  if $hosts.empty() {
    $ret = []
  } else {
    $ret = jqlib::puppetdb_query($pql)
      .map |Hash $host| { [$host['value']['ip'], $host['value']['ip6']] }
      .flatten
      .filter |$x| { $x =~ NotUndef and $x !~ /^fe80/ }
      .unique
      .sort
  }

  $ret
}
