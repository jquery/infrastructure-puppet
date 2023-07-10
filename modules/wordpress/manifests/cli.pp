# @summary installs and manages the wordpress cli
class wordpress::cli (
  String[1] $version,
) {
  file { '/usr/share/wp-cli':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
  }

  exec { 'wp-cli-download':
    command => "/usr/bin/curl -L -o /usr/share/wp-cli/wp-${version}.phar https://github.com/wp-cli/wp-cli/releases/download/v${version}/wp-cli-${version}.phar",
    creates => "/usr/share/wp-cli/wp-${version}.phar",
    require => Package['curl'],  # from the base profile
  }

  file { "/usr/share/wp-cli/wp-${version}.phar":
    ensure  => file,
    replace => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    require => Exec['wp-cli-download'],
  }

  file { '/usr/local/bin/wp':
    ensure  => link,
    target  => "/usr/share/wp-cli/wp-${version}.phar",
    require => Exec['wp-cli-download'],
  }

  file { '/etc/nginx/wordpress-subsites':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nginx'],
    notify  => Exec['nginx-reload'],
  }
}
