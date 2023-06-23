# @summary picks the certificate with the specified name
function profile::certbot::pick_certificate (
  Stdlib::Fqdn $fqdn
) >> Optional[String[1]] {
  $matching = $profile::certbot::certificates.filter |String[1] $name, Profile::Certbot::Certificate $cert| {
    $fqdn in $cert['domains']
  }.keys

  if $matching.length() == 1 {
    $ret = $matching[0]
  } else {
    $ret = undef
  }
}
