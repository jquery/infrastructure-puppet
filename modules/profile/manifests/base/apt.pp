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
}
