# @summary misc server for redirects and static version-controlled content
class profile::miscweb (
  Stdlib::Fqdn                                   $podcast_vhost = lookup('profile::miscweb::podcast_vhost'),
  Hash[Stdlib::Fqdn, Profile::Miscweb::Redirect] $redirects     = lookup('profile::miscweb::redirects'),
) {
  nftables::allow { 'miscweb-https':
    proto => 'tcp',
    dport => 443,
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
      Letsencrypt::Certificate['miscweb'],
      Git::Clone['jquerypodcast'],
    ],
  }

  $redirects.each |Stdlib::Fqdn $fqdn, Profile::Miscweb::Redirect $redirect| {
    $matching_cert = profile::certbot::pick_certificate($fqdn)
    if $redirect['certificate'] {
      $certificate = $redirect['certificate']
    } elsif $matching_cert {
      $certificate = $matching_cert
    } else {
      fail("Missing certificate for redirect ${fqdn}")
    }

    if 'permanent' in $redirect {
      $status_code = $redirect['permanent'].bool2str(301, 302)
    } else {
      $status_code = 301
    }

    if $redirect['target'].stdlib::end_with('/') {
      fail("Redirect ${fqdn} target must not end with a slash")
    }

    nginx::site { $fqdn:
      content => template('profile/miscweb/redirect.nginx.erb'),
      require => Letsencrypt::Certificate[$certificate],
    }
  }
}
