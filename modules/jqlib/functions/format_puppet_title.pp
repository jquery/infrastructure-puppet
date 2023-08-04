# @summary capitalizes a puppet class title
function jqlib::format_puppet_title (
  String[1] $input
) >> String {
  $input.split('::').capitalize.join('::')
}
