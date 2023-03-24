# @summary documentation wordpress sites
class profile::wordpress::docs (
  Profile::Docs::Sites $sites            = lookup('docs_sites'),
  String[1]            $db_password_seed = lookup('profile::wordpress::docs::db_password_seed'),
  Stdlib::Email        $admin_email      = lookup('profile::wordpress::docs::admin_email'),
  String[1]            $admin_password   = lookup('profile::wordpress::docs::admin_password'),
) {
  include profile::wordpress::base

  git::clone { 'jquery-wp-content':
    path   => '/srv/wordpress/jquery-wp-content',
    remote => 'https://github.com/jquery/jquery-wp-content',
    branch => 'main',
    owner  => 'www-data',
    group  => 'www-data',
  }

  $sites.each |String[1] $name, Profile::Docs::Site $site| {
    $active_theme = $site['active_theme']
    wordpress::site { $name:
      host             => $site['host'],
      site_name        => $site['site_name'],
      certificate      => $site['certificate'],
      db_password_seed => $db_password_seed,
      admin_email      => $admin_email,
      admin_password   => $admin_password,
      base_path        => "/srv/wordpress/sites/${name}",
      active_theme     => $active_theme,
      themes           => [
        { name => 'jquery',      path => '/srv/wordpress/jquery-wp-content/themes/jquery', },
        { name => $active_theme, path => "/srv/wordpress/jquery-wp-content/themes/${active_theme}", },
      ],
      options          => [],
    }
  }

  nftables::allow { 'wordpress-docs-https':
    proto => 'tcp',
    dport => 443,
  }
}
