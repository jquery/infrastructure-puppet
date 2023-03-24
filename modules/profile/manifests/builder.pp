# @summary updates the docs wordpress sites
class profile::builder (
  Profile::Docs::Sites $sites                 = lookup('docs_sites'),
  Stdlib::Fqdn         $docs_active_host      = lookup('docs_active_host'),  # this is a hack
  String[1]            $builder_password_seed = lookup('docs_builder_password_seed'),
) {
  ensure_packages(['nodejs', 'npm'])

  systemd::sysuser { 'builder':
    content => 'u builder - "unprivileged user for building doc sites" /srv/builder',
  }

  file { '/srv/builder':
    ensure => directory,
  }

  file { '/usr/local/bin/builder-do-update':
    ensure => file,
    source => 'puppet:///modules/profile/builder/builder-do-update.sh',
    owner  => '0555',
  }

  $sites.each |String[1] $name, Profile::Docs::Site $site| {
    git::clone { "builder-${name}":
      path    => "/srv/builder/${name}",
      remote  => 'https://github.com/gruntjs/gruntjs.com',
      branch  => 'main',
      owner   => 'builder',
      group   => 'builder',
      require => Service['systemd-sysusers'],
    }

    $settings = {
      url      => "https://${site['host']}",
      host     => $docs_active_host,
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
