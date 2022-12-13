# @summary installs certbot
# @param $email email to use for notifications
class profile::certbot (
  Stdlib::Email                                  $email        = lookup('profile::certbot::email'),
  Hash[String[1], Profile::Certbot::Certificate] $certificates = lookup('profile::certbot::certificates', {default_value => []}),
) {
  include ::profile::nginx

  class { 'letsencrypt::certbot':
    email => $email,
  }

  nftables::allow { 'certbot-http':
    proto => 'tcp',
    dport => 80,
  }

  $certificates.each |String[1] $name, Profile::Certbot::Certificate $data| {
    letsencrypt::certificate { $name:
      *       => $data,
      require => [Exec['nginx-default-site-reload'], Service['nftables']],
    }
  }
}
