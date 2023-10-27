# WordPress usage

We run two quite different types of WordPress installations:
* The `blogs` servers host blog.jquery.com, blog.jqueryui.com and
  blog.jquerymobile.com. These are edited by humans who have accounts
  that they use to log in to the WordPress admin interface directly.
* The `docs` sites host everything else. This is a collection of
  about 20 sites that are directly provisioned from Git repositories
  using the [grunt-jquery-content] system.

[jquery-wp-content]: https://github.com/jquery/grunt-jquery-content/

All of the WordPress settings are managed by Puppet. The sites are
backed by a locally running MariaDB instance.

## WordPress versions

By default we have WordPress auto upgrades enabled. If you want to pin
a specific version or to rollback to an older one, set one of these
hiera keys in `common.yaml` to the version you want to use:
```yaml
profile::wordpress::blogs::wordpress_version: ''
profile::wordpress::docs::wordpress_version: ''
```

You might need to restore the database from a backup if you had to roll
back to an older version with an older database schema.

## Backups

We keep Tarsnap backups for the databases and (for blogs) uploads. See
the [backup.md] file for details.

[backup.md]: ./backup.md

## Blog sites

* https://blog.jquery.com
* https://blog.jqueryui.com
* https://blog.jquerymobile.com

The canonical RSS feed is <https://blog.jquery.com/feed/>, but
subscribers also use the following aliases:
* https://feeds.feedburner.com/jquery/
* https://jquery.com/blog/feed/

### Blog accounts

The WordPress hosts can't send mail, so a normal password reset can't
be done that way. Instead it's possible to reset a lost password with
the `wp` CLI utility:
1. Log in to the active `wpblogs` host
2. Navigate to the correct directory under `/srv/wordpress/sites/`, for
   example `/srv/wordpress/sites/jquery/` for blog.jquery.com.
3. Run `sudo -u www-data wp user reset-password <USERNAME> --skip-email --show-password`
4. Log in via wp-admin, and maybe set a new password other than the
   randomly generated one?

## Doc sites

### Webhooks

There are token-secured and SSL-verified webhooks for [github.com/jquery](https://github.com/organizations/jquery/settings/hooks/) (organisztion-wide) that notify the `builder` and `wp` hosts
of push events (commits and tags) to all repositories.

### Builder hosts

The docs sites are provisioned by the `builder` hosts. These run
`node-notifier` to pick up changes to the sites and then run Grunt to
perform the upgrade. All of the configuration (including user
management) is handled by Puppet.
