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

  file { '/etc/letsencrypt/cli.ini':
    ensure  => file,
    mode    => '0444',
    content => template('letsencrypt/cli.ini.erb'),
    require => Exec['certbot-register'],
  }

  systemd::override { 'certbot-renew-no-quiet':
    unit   => 'certbot.service',
    source => 'puppet:///modules/letsencrypt/override-no-quiet.conf',
  }

  File <| tag == 'letsencrypt-hook' |>
}
