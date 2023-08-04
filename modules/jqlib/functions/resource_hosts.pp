# @summary function to return a list of hosts running a specific resource
function jqlib::resource_hosts (
  String[1]           $resource_type,
  Optional[String[1]] $resource_title = undef,
) >> Array[Stdlib::Host] {
  $title_query = $resource_title ? {
    undef   => '',
    default => " and title = \"${resource_title}\"",
  }

  $pql = @("PQL")
  resources[certname] {
    type = "${resource_type.split('::').capitalize.join('::')}" ${title_query}
  }
  | PQL

  jqlib::puppetdb_query($pql).map |Hash $resource| { $resource['certname'] }.unique.sort
}
