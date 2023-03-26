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
      plugins          => [
        { name => 'gilded-wordpress', path => '/srv/wordpress/jquery-wp-content/mu-plugins/gilded-wordpress.php', single_file => false, },
      ],
      options          => [],
      users            => [
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
  }

  nftables::allow { 'wordpress-docs-https':
    proto => 'tcp',
    dport => 443,
  }
}