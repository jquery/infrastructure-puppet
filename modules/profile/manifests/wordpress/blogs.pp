# @summary various blog sites
class profile::wordpress::blogs (
  Profile::Wordpress::Blogs::Sites $sites            = lookup('profile::wordpress::blogs::sites'),
  String[1]                        $db_password_seed = lookup('profile::wordpress::blogs::db_password_seed'),
) {
  include profile::wordpress::base

  $sites.each |String[1] $name, Hash $site| {
    wordpress::site { $name:
      *                => $site,
      db_password_seed => $db_password_seed,
    }
  }
}
