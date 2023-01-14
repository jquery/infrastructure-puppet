# @summary loads the content of a file in the private repository
function jqlib::secret (
  String $name,
) >> String {
  # this is a hack
  $use_fake_private = lookup('jqlib::secret::use_fake_private', {default_value => false})
  if $use_fake_private {
    $mod_path = get_module_path('jqlib')
    $private_path = "${mod_path}/../../test_data/private"
  } else {
    $private_path = "/srv/git/puppet/private"
  }

  $val = file("${private_path}/files/${name}")
  $val
}
