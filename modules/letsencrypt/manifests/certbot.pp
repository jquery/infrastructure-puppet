# @summary installs certbot
# @param $email email to use for notifications
class letsencrypt::certbot (
  Stdlib::Email $email,
) {
  ensure_packages(['certbot'])

  exec { 'certbot-register':
    command => "/usr/bin/certbot register --email ${email} --agree-tos --no-eff-email",
    creates => '/etc/letsencrypt/accounts'
  }

  # shared directory for acme challenges
  file { [
    '/var/www/letsencrypt',
    '/var/www/letsencrypt/.well-known',
    '/var/www/letsencrypt/.well-known/acme-challenge/',
  ]:
    ensure => directory,
  }
}
