# @summary updates the docs wordpress sites
class profile::builder (
  Profile::Docs::Sites $sites                 = lookup('docs_sites'),
  Stdlib::Fqdn         $docs_active_host      = lookup('docs_active_host'),
  String[1]            $builder_password_seed = lookup('docs_builder_password_seed'),
) {
  ensure_packages([
    'nodejs',
    'npm',

    # tools needed by some sites:
    'graphicsmagick',
    'imagemagick',
    'libxml2-utils',  # for xmllint
    'xsltproc',
  ])

  systemd::sysuser { 'builder':
    content => 'u builder - "unprivileged user for building doc sites" /srv/builder',
  }

  file { '/srv/builder':
    ensure => directory,
  }

  # npm cache in builder user home directory
  file { '/srv/builder/.npm':
    ensure => directory,
    owner  => 'builder',
    group  => 'builder',
  }

  file { '/usr/local/bin/builder-do-update':
    ensure => file,
    source => 'puppet:///modules/profile/builder/builder-do-update.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }

  $sites.each |String[1] $name, Profile::Docs::Site $site| {
    git::clone { "builder-${name}":
      path    => "/srv/builder/${name}",
      remote  => "https://github.com/${site['repository']['name']}",
      branch  => $site['repository']['branch'],
      owner   => 'builder',
      group   => 'builder',
      require => Service['systemd-sysusers'],
    }

    $path = pick($site['path'], '/')
    $active_host = pick($site['active_host'], $docs_active_host)
    $settings = {
      url      => "https://${site['host']}${path}",
      host     => $active_host,
      username => 'builder',
      password => jqlib::autogen_password("docs_builder_${name}", $builder_password_seed),
      dir      => 'dist/wordpress',
    } + pick($site['builder_extra_settings'], {})

    file { "/srv/builder/${name}/config.json":
      ensure  => file,
      content => $settings.to_json_pretty(),
      owner   => 'builder',
      group   => 'builder',
      mode    => '0440',
      require => Git::Clone["builder-${name}"],
    }

    notifier::git_update { "builder-${name}":
      github_repository => $site['repository']['name'],
      listen_for        => [{ branch => $site['repository']['branch'] }],
      local_path        => "/srv/builder/${name}",
      local_user        => 'builder',
      extra_commands    => ["/usr/local/bin/builder-do-update /srv/builder/${name}"],
      require           => Git::Clone["builder-${name}"],
    }
  }
}
