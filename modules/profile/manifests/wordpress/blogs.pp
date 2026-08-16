# @summary various blog sites
class profile::wordpress::blogs (
  Profile::Wordpress::Blogs::Sites $sites             = lookup('profile::wordpress::blogs::sites'),
  Optional[String[1]]              $wordpress_version = lookup('profile::wordpress::blogs::wordpress_version'),
  String[1]                        $db_password_seed  = lookup('profile::wordpress::blogs::db_password_seed'),
  Stdlib::Email                    $admin_email       = lookup('profile::wordpress::blogs::admin_email'),
  String[1]                        $admin_password    = lookup('profile::wordpress::blogs::admin_password'),
) {
  include profile::wordpress::base

  git::clone { 'jquery-wp-content':
    path   => '/srv/wordpress/jquery-wp-content',
    remote => 'https://github.com/jquery/jquery-wp-content',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  notifier::git_update { 'jquery-wp-content':
    github_repository => 'jquery/jquery-wp-content',
    listen_for        => [{ branch => 'main' }],
    local_path        => '/srv/wordpress/jquery-wp-content',
    local_user        => 'www-data',
    require           => Git::Clone['jquery-wp-content'],
  }

  $sites.each |String[1] $name, Hash $site| {
    $active_theme = $site['active_theme']
    $dir = "/srv/wordpress/sites/${name}"
    $host = $site['host']

    file { "${dir}/jquery-config.php":
      ensure  => file,
      content => template('profile/wordpress/blogs/jquery-config.php.erb'),
      require => Exec["wp-download-${name}"],
    }

    wordpress::site { $name:
      *                => $site,
      path             => '/',
      version          => $wordpress_version,
      db_password_seed => $db_password_seed,
      admin_email      => $admin_email,
      admin_password   => $admin_password,
      config_files     => [
        "${dir}/jquery-config.php",
      ],
      themes           => [
        { name => 'jquery',      path => '/srv/wordpress/jquery-wp-content/themes/jquery', },
        { name => $active_theme, path => "/srv/wordpress/jquery-wp-content/themes/${active_theme}", },
      ],
      plugins          => [
        { name => 'disable-emojis', path => '/srv/wordpress/jquery-wp-content/plugins/disable-emojis/disable-emojis.php', single_file => true, },
        { name => 'two-factor', path => '/srv/wordpress/jquery-wp-content/plugins/two-factor', single_file => false, },
        { name => 'jquery-actions', path => '/srv/wordpress/jquery-wp-content/plugins/jquery-actions.php', single_file => true, },
        { name => 'jquery-filters', path => '/srv/wordpress/jquery-wp-content/plugins/jquery-filters.php', single_file => true, },
      ],
      base_path        => $dir,
    }
  }

  tarsnap::backup { 'wordpress':
    paths => $sites.keys.map |String[1] $site| { "/srv/wordpress/sites/${site}/wp-content/uploads/" },
  }

  nftables::allow { 'wordpress-blogs-https':
    proto => 'tcp',
    dport => 443,
  }

  class { 'tarsnap::mariadb':
    database_pattern => 'wordpress\\_%',
  }
}
