# @summary configures node-notifier and exposes it via tls
class profile::notifier (
  String[1] $webhook_secret = lookup('profile::notifier::webhook_secret'),
  String[1] $tls_key_name   = lookup('profile::notifier::tls_key_name'),
) {
  class { 'notifier':
    webhook_secret => $webhook_secret,
  }

  nftables::allow { 'notifier-https':
    proto => 'tcp',
    dport => 8333,
  }

  # TODO: maybe we want to request our own certificates for this?
  # that way the main certs don't need to contain the hostname

  $tls_config = nginx::tls_config()

  nginx::site { 'notifier':
    content => template('profile/notifier/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }
}
