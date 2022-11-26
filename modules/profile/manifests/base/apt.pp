# @summary configures apt
class profile::base::apt (
  Array[Debian::Codename] $security_supported_versions = lookup('profile::base::apt::security_supported_versions'),
) {
  class { 'apt':
    update => {
      frequency => 'daily',
    },
    purge  => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences'    => true,
      'preferences.d'  => true,
    },
  }

  file { '/etc/apt/keyrings':
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  $codename = debian::codename()

  apt::source { 'main':
    location => 'http://deb.debian.org/debian/',
    repos    => 'main',
  }

  apt::source { 'updates':
    location => 'http://deb.debian.org/debian/',
    repos    => 'main',
    release  => "${codename}-updates"
  }

  if $codename in $security_supported_versions {
    apt::source { 'security':
      location => 'http://security.debian.org/debian-security/',
      repos    => 'main',
      release  => "${codename}-security"
    }
  }

  # configure default behaviour for config file updates: use the default specified by the package,
  # or fall back to the old file if no default has been specified
  apt::conf { 'dpkg-options-confdef':
    priority => '00',
    content  => 'Dpkg::Options:: "--force-confdef";',
  }
  apt::conf { 'dpkg-options-confold':
    priority => '00',
    content  => 'Dpkg::Options:: "--force-confold";',
  }

  ensure_packages(['unattended-upgrades'])

  apt::conf { 'auto-upgrades':
    priority => '20',
    content  => 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";',
  }

  apt::conf { 'unattended-upgrades-updates':
    priority => '30',
    # lint:ignore:single_quote_string_with_variables
    content  => 'Unattended-Upgrade::Origins-Pattern:: "origin=${distro_id},codename=${distro_codename}-updates";',
    # lint:endignore
  }

  apt::conf { 'unattended-upgrades-security':
    priority => '30',
    # lint:ignore:single_quote_string_with_variables
    content  => 'Unattended-Upgrade::Origins-Pattern:: "origin=${distro_id},codename=${distro_codename}-security";',
    # lint:endignore
  }

  apt::conf { 'autoclean':
    priority => '50',
    content  => 'APT::Periodic::AutocleanInterval 14;',
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure => absent,
  }
}
