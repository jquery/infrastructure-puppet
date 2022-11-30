# @summary generates and maintains a certificate with the webroot hook
# @param $domains certificate subjects
define letsencrypt::certificate (
  Array[Stdlib::Fqdn, 1] $domains,
) {
  require letsencrypt::certbot

  $base_command = "/usr/bin/certbot certonly --cert-name ${title} --non-interactive"
  $domains_command = $domains.map |Stdlib::Fqdn $domain| {
    "-d ${domain}"
  }.join(' ')

  # TODO: replace the cert if the domains change
  exec { "letsencrypt-request-${title}":
    command   => "${base_command} ${domains_command}",
    creates   => "/etc/letsencrypt/live/${title}",
    logoutput => true,
  }
}
