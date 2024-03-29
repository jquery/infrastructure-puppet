# @summary installs certbot
# @param $email email to use for notifications
class letsencrypt::certbot (
  Stdlib::Email $email,
) {
  ensure_packages([
    'certbot',
    'python3-cryptography',
  ])

  file { '/usr/local/bin/cert-compare':
    ensure => file,
    source => 'puppet:///modules/letsencrypt/cert-compare.py',
    mode   => '0555',
  }

  exec { 'certbot-register':
    command => "/usr/bin/certbot register --email ${email} --agree-tos --no-eff-email",
    creates => '/etc/letsencrypt/accounts',
    require => Package['certbot'],
  }

  # shared directory for acme challenges
  file { [
    '/var/www/letsencrypt',
    '/var/www/letsencrypt/.well-known',
    '/var/www/letsencrypt/.well-known/acme-challenge/',
  ]:
    ensure  => directory,
    require => Package['nginx-full'],
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

  File <| tag == 'letsencrypt-hook' |> {
    require => Package['certbot'],
  }
}
