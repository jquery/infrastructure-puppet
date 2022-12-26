# @summary origin server for content. and static. content
class profile::contentorigin (
  Hash[Stdlib::Fqdn, Profile::Contentorigin::Site] $sites = lookup('profile::contentorigin::sites'),
) {
  nftables::allow { 'contentorigin-https':
    proto => 'tcp',
    dport => 443,
  }

  $tls_config = nginx::tls_config()

  file { '/srv/www':
    ensure => directory,
  }

  $sites.each |Stdlib::Fqdn $host, Profile::Contentorigin::Site $site| {
    file { "/srv/www/${host}":
      ensure => directory,
    }

    nginx::site { $host:
      content => template('profile/contentorigin/site.nginx.erb'),
      require => Letsencrypt::Certificate[$site['certificate']],
    }
  }
}
