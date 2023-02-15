# @summary miscweb server for various redirects and static version-controlled content
class profile::miscweb (
  Hash[Stdlib::Fqdn, Profile::Miscweb::Site] $sites = lookup('profile::miscweb::sites'),
) {
  nftables::allow { 'miscweb-https':
    proto => 'tcp',
    dport => 443,
  }

  $tls_config = nginx::tls_config()

  file { '/srv/www':
    ensure => directory,
  }

  $sites.each |Stdlib::Fqdn $host, Profile::Miscweb::Site $site| {
    file { "/srv/www/${host}":
      ensure => directory,
    }

    nginx::site { $host:
      content => template('profile/miscweb/site.nginx.erb'),
      require => Letsencrypt::Certificate[$site['certificate']],
    }
  }
}
