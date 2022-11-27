# @summary provisions a puppetdb server
class profile::puppet::puppetdb (
  String[1] $postgresql_password = lookup('profile::puppet::puppetdb::postgresql_password'),
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
}
