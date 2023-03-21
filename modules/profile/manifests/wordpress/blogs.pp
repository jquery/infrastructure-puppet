# @summary various blog sites
class profile::wordpress::blogs (
  Profile::Wordpress::Blogs::Sites $sites            = lookup('profile::wordpress::blogs::sites'),
  String[1]                        $db_password_seed = lookup('profile::wordpress::blogs::db_password_seed'),
  Stdlib::Email                    $admin_email      = lookup('profile::wordpress::blogs::admin_email'),
  String[1]                        $admin_password   = lookup('profile::wordpress::blogs::admin_password'),
) {
  include profile::wordpress::base

  $sites.each |String[1] $name, Hash $site| {
    wordpress::site { $name:
      *                => $site,
      db_password_seed => $db_password_seed,
      admin_email      => $admin_email,
      admin_password   => $admin_password,
      base_path        => "/srv/wordpress/sites/${name}",
    }
  }

  nftables::allow { 'wordpress-blogs-https':
    proto => 'tcp',
    dport => 443,
  }
}
