# @summary misc server for redirects and static version-controlled content
class profile::miscweb (
  Stdlib::Fqdn                                   $podcast_vhost       = lookup('profile::miscweb::podcast_vhost'),
  String[1]                                      $default_certificate = lookup('profile::miscweb::default_certificate'),
  Hash[Stdlib::Fqdn, Profile::Miscweb::Redirect] $redirects           = lookup('profile::miscweb::redirects'),
) {
  nftables::allow { 'miscweb-https':
    proto => 'tcp',
    dport => 443,
  }
  nftables::allow { 'miscweb-http':
    proto => 'tcp',
    dport => 80,
  }

  git::clone { 'jquerypodcast':
    path   => '/srv/jquerypodcast',
    remote => 'https://github.com/jquery/podcast.jquery.com',
    branch => 'main',
    owner  => 'root',
    group  => 'www-data',
  }

  $tls_config = nginx::tls_config()

  nginx::site { $podcast_vhost:
    content => template('profile/miscweb/jquerypodcast.nginx.erb'),
    require => [
      Letsencrypt::Certificate[$default_certificate],
      Git::Clone['jquerypodcast'],
    ],
  }

  profile::miscweb::group_certificates($redirects).each |String[1] $name, Array[Stdlib::Fqdn] $domains| {
    letsencrypt::certificate { $name:
      domains => $domains,
      require => [Exec['nginx-default-site-reload'], Service['nftables']],
    }
  }

  $redirects.each |Stdlib::Fqdn $fqdn, Profile::Miscweb::Redirect $redirect| {
    $certificate = pick($redirect['certificate'], $default_certificate)

    if 'permanent' in $redirect {
      $status_code = $redirect['permanent'].bool2str(301, 302)
    } else {
      $status_code = 301
    }

    if $redirect['mode'] == 'prefix' and $redirect['target'].stdlib::end_with('/') {
      fail("Redirect ${fqdn} target must not end with a slash")
    }

    nginx::site { $fqdn:
      content => template('profile/miscweb/redirect.nginx.erb'),
      require => Letsencrypt::Certificate[$certificate],
    }
  }
}
