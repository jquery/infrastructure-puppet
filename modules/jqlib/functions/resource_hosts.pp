# @summary function to return a list of hosts running a specific resource
function jqlib::resource_hosts (
  String[1]           $resource_type,
  Optional[String[1]] $resource_title   = undef,
  Boolean             $all_environments = false,
) >> Array[Stdlib::Host] {
  $title_query = $resource_title ? {
    undef   => '',
    default => "and title = \"${jqlib::format_puppet_title($resource_title)}\"",
  }
  $environment_query = $all_environments.bool2str('', "and environment = \"${::environment}\"")

  $pql = @("PQL")
  resources[certname] {
    type = "${jqlib::format_puppet_title($resource_type)}"
    ${title_query}
    ${environment_query}
  }
  | PQL

  jqlib::puppetdb_query($pql).map |Hash $resource| { $resource['certname'] }.unique.sort
}
