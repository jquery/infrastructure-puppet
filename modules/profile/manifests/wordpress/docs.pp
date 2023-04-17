# @summary documentation wordpress sites
class profile::wordpress::docs (
  Profile::Docs::Sites $sites                 = lookup('docs_sites'),
  String[1]            $db_password_seed      = lookup('profile::wordpress::docs::db_password_seed'),
  Stdlib::Email        $admin_email           = lookup('profile::wordpress::docs::admin_email'),
  String[1]            $admin_password        = lookup('profile::wordpress::docs::admin_password'),
  Stdlib::Email        $builder_email         = lookup('profile::wordpress::docs::builder_email'),
  String[1]            $builder_password_seed = lookup('docs_builder_password_seed'),
) {
  include profile::wordpress::base

  git::clone { 'jquery-wp-content':
    path   => '/srv/wordpress/jquery-wp-content',
    remote => 'https://github.com/jquery/jquery-wp-content',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  file { '/srv/wordpress/docs-config-shared.php':
    ensure => file,
    source => 'puppet:///modules/profile/wordpress/docs/config.php',
  }

  $sites.each |String[1] $name, Profile::Docs::Site $site| {
    $active_theme = $site['active_theme']

    $base_plugins = [
      { name => 'gilded-wordpress', path => '/srv/wordpress/jquery-wp-content/mu-plugins/gilded-wordpress.php',              single_file => true, },
      { name => 'redirects',        path => '/srv/wordpress/jquery-wp-content/mu-plugins/redirects.php',                     single_file => true, },
      { name => 'disable-emojis',   path => '/srv/wordpress/jquery-wp-content/mu-plugins/disable-emojis/disable-emojis.php', single_file => true, },
      { name => 'jquery-actions',   path => '/srv/wordpress/jquery-wp-content/mu-plugins/jquery-actions.php',                single_file => true, },
      { name => 'jquery-filters',   path => '/srv/wordpress/jquery-wp-content/mu-plugins/jquery-filters.php',                single_file => true, },
    ]

    if $site['enable_static_index'] {
      $static_index_plugins = [
        { name => 'jquery-static-index', path => '/srv/wordpress/jquery-wp-content/plugins/jquery-static-index.php', single_file => true, },
      ]
    } else {
      $static_index_plugins = []
    }

    wordpress::site { $name:
      host                => $site['host'],
      site_name           => $site['site_name'],
      certificate         => $site['certificate'],
      db_password_seed    => $db_password_seed,
      admin_email         => $admin_email,
      admin_password      => $admin_password,
      base_path           => "/srv/wordpress/sites/${name}",
      permalink_structure => '/%postname%/',
      config_files        => [
        '/srv/wordpress/docs-config-shared.php',
        "/srv/wordpress/sites/${name}/jquery-config.php",
      ],
      active_theme        => $active_theme,
      themes              => [
        { name => 'jquery',      path => '/srv/wordpress/jquery-wp-content/themes/jquery', },
        { name => $active_theme, path => "/srv/wordpress/jquery-wp-content/themes/${active_theme}", },
      ],
      plugins             => $base_plugins + $static_index_plugins,
      options             => [],
      users               => [
        {
          username => 'builder',
          password => jqlib::autogen_password("docs_builder_${name}", $builder_password_seed),
          email    => $builder_email,
          # I think this is needed to edit content pages, menus and similar.
          # TODO: check if we can use a role with less privs.
          role     => 'administrator',
        }
      ],
    }

    $live_site = regsubst($site['host'], '^stage\.(.*)$', '\1')
    file { "/srv/wordpress/sites/${name}/jquery-config.php":
      ensure  => file,
      content => template('profile/wordpress/docs/jquery-config.php.erb'),
      require => Exec["wp-download-${name}"],
    }
  }

  nftables::allow { 'wordpress-docs-https':
    proto => 'tcp',
    dport => 443,
  }
}
