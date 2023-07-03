# @summary queries puppetdb if possible
function jqlib::puppetdb_query (
  String[1] $query
) >> Array[Hash] {
  if jqlib::has_puppetdb() {
    puppetdb_query($query)
  } else {
    []
  }
}
