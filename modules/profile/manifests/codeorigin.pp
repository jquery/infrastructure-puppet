# @summary code origin server
# @param $cdn_access_key cdn access key
class profile::codeorigin (
  String                 $cdn_access_key  = lookup('profile::codeorigin::cdn_access_key'),
  Array[Stdlib::Fqdn, 1] $vhost_hostnames = lookup('profile::codeorigin::vhost_hostnames'),
  Boolean                $serve_plaintext = lookup('profile::codeorigin::serve_plaintext', {default_value => false}),
) {
  include ::profile::nginx

  git::clone { 'codeorigin':
    path   => '/srv/codeorigin',
    remote => 'https://github.com/jquery/codeorigin.jquery.com',
    branch => 'main',
    owner  => 'root',
    group  => 'www-data',
  }

  file { '/srv/codeorigin/.git/hooks/post-merge':
    ensure => file,
    source => 'puppet:///modules/profile/codeorigin/set-last-modified.sh',
    mode   => '0555',
    notify => Exec['codeorigin-set-last-modified-initial'],
  }

  exec { 'codeorigin-set-last-modified-initial':
    command     => '/srv/codeorigin/.git/hooks/post-merge',
    refreshonly => true,
  }

  notifier::git_update { 'codeorigin':
    github_repository => 'jquery/codeorigin.jquery.com',
    listen_for        => [{ branch => 'main' }],
    local_path        => '/srv/codeorigin',
    local_user        => 'root',
  }

  nftables::allow { 'codeorigin-https':
    proto => 'tcp',
    dport => 443,
  }

  $tls_config = nginx::tls_config()

  nginx::site { 'codeorigin':
    content => template('profile/codeorigin/site.nginx.erb'),
    require => Letsencrypt::Certificate['codeorigin'],
  }
}
