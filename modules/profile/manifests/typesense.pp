# @summary Install Typesense and exposes it via TLS
class profile::typesense (
  String[1] $tls_key_name = lookup('profile::typesense::tls_key_name'),
  String[1] $api_key = lookup('profile::typesense::api_key'),
) {
  class { 'typesense':
    api_key => $api_key,
  }

  nftables::allow { 'typesense-https':
    proto => 'tcp',
    dport => 443,
  }

  $backend_port = 8108
  $tls_config = nginx::tls_config()

  nginx::site { 'typesense':
    content => template('profile/typesense/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }
}
