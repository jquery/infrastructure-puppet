# @summary provisions a puppetdb server
class profile::puppet::puppetdb (
  String[1]        $postgresql_password    = lookup('profile::puppet::puppetdb::postgresql_password'),
  Array[String[1]] $nginx_htpassword_users = lookup('profile::puppet::puppetdb::nginx_htpassword_users'),
) {
  include profile::puppet::common

  # at least for now, the database is always on the same host
  include profile::puppet::puppetdb_database

  package { 'puppetdb':
    ensure => installed,
  }

  $puppetservers = [$::facts['fqdn']]

  file { '/etc/puppetlabs/puppetdb/cert-allowlist':
    ensure  => file,
    mode    => '0444',
    content => "${puppetservers.join("\n")}\n",
    notify  => Service['puppetdb'],
  }

  ['config.ini', 'database.ini'].each |String $file| {
    file { "/etc/puppetlabs/puppetdb/conf.d/${file}":
      ensure    => file,
      mode      => '0440',
      group     => 'puppetdb',
      content   => template("profile/puppet/puppetdb/config/${file}.erb"),
      show_diff => false,
      notify    => Service['puppetdb'],
    }
  }

  service { 'puppetdb':
    ensure => running,
    enable => true,
  }

  # expose an authenticated version of the puppetdb api,
  # so that octocatalog-diff can be used locally with facts loaded from puppetdb
  $tls_config = nginx::tls_config()
  nginx::site { 'puppetdb-external':
    content => template('profile/puppet/puppetdb/site.nginx.erb'),
  }

  file { '/etc/nginx/puppetdb.htpasswd':
    ensure  => file,
    mode    => '0440',
    group   => 'www-data',
    content => "${nginx_htpassword_users.join("\n")}\n",
    require => Package['nginx-full'],
  }

  nftables::allow { 'puppetdb-external':
    proto => 'tcp',
    dport => 8100,
  }
}
