# @summary misc server for redirects and static version-controlled content
class profile::miscweb (
  Stdlib::Fqdn $podcast_vhost = lookup('profile::miscweb::podcast_vhost'),
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
}
