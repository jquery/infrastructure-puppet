# @summary a simple alias to $facts['os']['name']['codename']
# @return [String] the codename of this debian installation
function debian::codename () >> String {
  $facts['os']['distro']['codename']
}
