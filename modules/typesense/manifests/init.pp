# @summary Install Typesense
class typesense (
  String[1] $api_key,
  String[1] $version = '0.24.0',
) {

  file { '/usr/share/typesense-dl':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
  }

  $deb = "/usr/share/typesense-dl/typesense-server-${version}-amd64.deb"

  exec { 'typesense-download':
    command => "/usr/bin/curl -L -o ${deb} https://dl.typesense.org/releases/${version}/typesense-server-${version}-amd64.deb",
    creates => $deb,
    require => Package['curl'], # from the base profile
  }

  file { $deb:
    ensure  => file,
    replace => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    require => Exec['typesense-download'],
  }

  # The package takes care of the following following:
  #
  # - create /etc/typesense/typesense-server.ini (with random $API_KEY)
  # - create /usr/bin/typesense-server
  # - create /var/lib/typesense (database)
  # - create /var/log/typesense
  # - create "typesense-server" service
  # - run `systemctl start typesense-server` (starts HTTP server on port 8108)
  #
  # Docs:
  #   https://typesense.org/docs/guide/install-typesense.html
  # Source:
  #   https://github.com/typesense/typesense/tree/0ac4feb68cf/debian-pkg/typesense-server
  #
  package { 'typesense-server':
    ensure => $version,
    source => $deb,
  }

  # The service should be restarted after an upgrade.
  # TODO: Does this happen automatically?
  # https://typesense.org/docs/guide/updating-typesense.html#updating-deb-package

  service { 'typesense-server':
    ensure => running,
    enable => true,
  }

  file { '/etc/typesense/typesense-server.ini':
    ensure  => file,
    content => template('typesense/server.ini.erb'),
    notify  => Service['typesense-server'],
  }
}
