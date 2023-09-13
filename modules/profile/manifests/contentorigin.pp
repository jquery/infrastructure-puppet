# @summary origin server for content.jquery.com
class profile::contentorigin (
  String[1]           $tls_key_name   = lookup('profile::contentorigin::tls_key_name'),
  Stdlib::Fqdn        $host           = lookup('profile::contentorigin::server_name'),
) {
  nftables::allow { 'contentorigin-https':
    proto => 'tcp',
    dport => 443,
  }

  $tls_config = nginx::tls_config()

  file { '/srv/www':
    ensure => directory,
  }

  file { '/srv/www/content.jquery.com':
    ensure => directory,
  }

  nginx::site { $host:
    content => template('profile/contentorigin/site.nginx.erb'),
    require => Letsencrypt::Certificate[$tls_key_name],
  }

  tarsnap::backup { 'contentorigin':
    paths => ['/srv/www'],
  }
}
