# @summary checks if puppetdb is available
function jqlib::has_puppetdb () >> Boolean {
  # this is a hack
  lookup('jqlib::has_puppetdb', {default_value => true})
}
