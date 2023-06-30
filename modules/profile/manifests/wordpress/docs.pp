# @summary documentation wordpress sites
class profile::wordpress::docs (
  Profile::Docs::Sites $sites                 = lookup('docs_sites'),
  String[1]            $wordpress_version     = lookup('profile::wordpress::docs::wordpress_version'),
  String[1]            $db_password_seed      = lookup('profile::wordpress::docs::db_password_seed'),
  Stdlib::Email        $admin_email           = lookup('profile::wordpress::docs::admin_email'),
  String[1]            $admin_password        = lookup('profile::wordpress::docs::admin_password'),
  Stdlib::Email        $builder_email         = lookup('profile::wordpress::docs::builder_email'),
  String[1]            $wp_content_branch     = lookup('profile::wordpress::docs::wp_content_branch'),
  String[1]            $builder_password_seed = lookup('docs_builder_password_seed'),
) {
  include profile::wordpress::base

  git::clone { 'jquery-wp-content':
    path   => '/srv/wordpress/jquery-wp-content',
    remote => 'https://github.com/jquery/jquery-wp-content',
    branch => $wp_content_branch,
    owner  => 'www-data',
    group  => 'www-data',
  }

  notifier::git_update { 'jquery-wp-content':
    github_repository => 'jquery/jquery-wp-content',
    listen_for        => [{ branch => $wp_content_branch }],
    local_path        => '/srv/wordpress/jquery-wp-content',
    local_user        => 'www-data',
    require           => Git::Clone['jquery-wp-content'],
  }

  file { '/srv/wordpress/docs-config-shared.php':
    ensure => file,
    source => 'puppet:///modules/profile/wordpress/docs/config.php',
  }

  $sites.each |String[1] $name, Profile::Docs::Site $site| {
    $active_theme = $site['active_theme']

    $path = pick($site['path'], '/')
    $dir = regsubst("/srv/wordpress/sites/${name}${path}", '^(.*)\/$', '\1')

    if $path != '/' {
      file { "/srv/wordpress/sites/${name}":
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
      }
    }

    $base_plugins = [
      { name => 'gilded-wordpress',     path => '/srv/wordpress/jquery-wp-content/mu-plugins/gilded-wordpress.php',              single_file => true, },
      { name => 'redirects',            path => '/srv/wordpress/jquery-wp-content/mu-plugins/redirects.php',                     single_file => true, },
      { name => 'disable-emojis',       path => '/srv/wordpress/jquery-wp-content/mu-plugins/disable-emojis/disable-emojis.php', single_file => true, },
      { name => 'jquery-actions',       path => '/srv/wordpress/jquery-wp-content/mu-plugins/jquery-actions.php',                single_file => true, },
      { name => 'jquery-filters',       path => '/srv/wordpress/jquery-wp-content/mu-plugins/jquery-filters.php',                single_file => true, },
      { name => 'jquery-tags-on-pages', path => '/srv/wordpress/jquery-wp-content/mu-plugins/jquery-tags-on-pages.php',          single_file => true, },
    ]

    if $site['enable_static_index'] {
      $static_index_plugins = [
        { name => 'jquery-static-index', path => '/srv/wordpress/jquery-wp-content/plugins/jquery-static-index.php', single_file => true, },
      ]
    } else {
      $static_index_plugins = []
    }

    if $site['enable_api_tweaks'] {
      if $path != '/' {
        $subsite_plugins = [
          { name => 'rewrite-old-api-links', path => '/srv/wordpress/jquery-wp-content/mu-plugins/rewrite-old-api-links.php', single_file => true },
        ]
      } else {
        $subsite_plugins = []
      }

      $api_site_plugins = [
        { name => 'category-listings', path => '/srv/wordpress/jquery-wp-content/mu-plugins/category-listings.php', single_file => true },
      ] + $subsite_plugins
    } else {
      $api_site_plugins = []
    }

    if $site['options'] {
      $options = $site['options'].map |String[1] $name, String $value| {
        { name => $name, value => $value }
      }
    } else {
      $options = []
    }

    wordpress::site { $name:
      host                => $site['host'],
      site_name           => $site['site_name'],
      path                => $path,
      webroot             => "/srv/wordpress/sites/${name}",
      version             => $wordpress_version,
      certificate         => $site['certificate'],
      db_password_seed    => $db_password_seed,
      admin_email         => $admin_email,
      admin_password      => $admin_password,
      base_path           => $dir,
      permalink_structure => '/%postname%/',
      gilded_wordpress    => true,
      config_files        => [
        '/srv/wordpress/docs-config-shared.php',
        "${dir}/jquery-config.php",
      ],
      active_theme        => $active_theme,
      themes              => [
        { name => 'jquery',      path => '/srv/wordpress/jquery-wp-content/themes/jquery', },
        { name => $active_theme, path => "/srv/wordpress/jquery-wp-content/themes/${active_theme}", },
      ],
      plugins             => $base_plugins + $static_index_plugins + $api_site_plugins,
      options             => $options,
      sidebars            => [
        { slot => 'sidebar-1', ensure => absent, },
      ],
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

    $live_domain = regsubst($site['host'], '^stage\.(.*)$', '\1')
    $live_site = regsubst("${live_domain}${path}", '^(.*)\/$', '\1')

    file { "${dir}/jquery-config.php":
      ensure  => file,
      content => template('profile/wordpress/docs/jquery-config.php.erb'),
      require => Exec["wp-download-${name}"],
    }

    if $site['redirects'] {
      file { "/etc/nginx/wordpress-subsites/${site['host']}.d/${name}.conf":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        content => template('profile/wordpress/docs/redirects.nginx.erb'),
        notify  => Exec['nginx-reload'],
      }
    }
  }

  nftables::allow { 'wordpress-docs-https':
    proto => 'tcp',
    dport => 443,
  }
}
