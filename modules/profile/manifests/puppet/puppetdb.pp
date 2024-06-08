# @summary provisions a puppetdb server
class profile::puppet::puppetdb (
  String[1]        $postgresql_password    = lookup('profile::puppet::puppetdb::postgresql_password'),
  String[1]        $nginx_certificate_name = lookup('profile::puppet::puppetdb::nginx_certificate_name'),
  Array[String[1]] $nginx_htpassword_users = lookup('profile::puppet::puppetdb::nginx_htpassword_users'),
) {
  include profile::puppet::common

  # at least for now, the database is always on the same host
  include profile::puppet::puppetdb_database

  package { 'puppetdb':
    ensure => installed,
  }

  $puppetservers = jqlib::resource_hosts('class', 'profile::puppet::server')
  $puppetservers_ips = $puppetservers.map |Stdlib::Fqdn $fqdn| { dnsquery::lookup($fqdn, true) }.flatten

  $config_path = debian::codename() ? {
    'bullseye' => '/etc/puppetlabs/puppetdb',
    default    => '/etc/puppetdb',
  }
  $var_path = debian::codename() ? {
    'bullseye' => '/opt/puppetlabs/server/data/puppetdb',
    default    => '/var/lib/puppetdb',
  }

  file { "${config_path}/cert-allowlist":
    ensure  => file,
    mode    => '0444',
    content => "${puppetservers.join("\n")}\n",
    notify  => Service['puppetdb'],
  }

  ['config.ini', 'database.ini'].each |String $file| {
    file { "${config_path}/conf.d/${file}":
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
    require => Letsencrypt::Certificate[$nginx_certificate_name],
  }

  file { '/etc/nginx/puppetdb.htpasswd':
    ensure    => file,
    mode      => '0440',
    group     => 'www-data',
    content   => "${nginx_htpassword_users.join("\n")}\n",
    require   => Package['nginx-full'],
    show_diff => false,
  }

  nftables::allow { 'puppetdb-clients':
    proto => 'tcp',
    dport => 8081,
    saddr => $puppetservers_ips,
  }

  nftables::allow { 'puppetdb-external':
    proto => 'tcp',
    dport => 8100,
  }
}
