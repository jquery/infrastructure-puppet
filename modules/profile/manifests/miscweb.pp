# @summary misc server for redirects and static version-controlled content
class profile::miscweb (
  String[1]                                      $default_certificate = lookup('profile::miscweb::default_certificate'),
  Hash[Stdlib::Fqdn, Profile::Miscweb::Site]     $sites               = lookup('profile::miscweb::sites'),
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

  $tls_config = nginx::tls_config()


  file { '/srv/www':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0775',
  }

  class { 'php': }
  class { 'php::fpm': }

  $php_fpm_version = $::php::fpm::version

  $sites.each |Stdlib::Fqdn $fqdn, Profile::Miscweb::Site $site| {
    $certificate = pick($site['certificate'], $default_certificate)

    git::clone { $fqdn:
      path   => "/srv/www/${fqdn}",
      remote => "https://github.com/${site['repository']['name']}",
      branch => $site['repository']['branch'],
      owner  => 'root',
      group  => 'root',
    }

    nginx::site { $fqdn:
      content => template('profile/miscweb/site.nginx.erb'),
      require => [
        Letsencrypt::Certificate[$certificate],
        Git::Clone[$fqdn],
      ],
    }
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
