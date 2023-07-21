# WordPress usage

We run two quite different types of WordPress installations:
* The `blogs` servers host blog.jquery.com, blog.jqueryui.com and
  blog.jquerymobile.com. These are edited by humans who have accounts
  that they use to log in to the WordPress interface directly.
* The `docs` sites includes everything else. This is a collection of
  about 20 sites that are directly provisioned from Git repositories
  using the [grunt-jquery-content] system.

[jquery-wp-content]: https://github.com/jquery/grunt-jquery-content/

All of the WordPress settings are managed by Puppet. The sites are
backed by a locally running MariaDB instance.

## Blog accounts

TODO.

## Builders

The docs sites are provisioned by the `builder` hosts. These run
`node-notifier` to pick up changes to the sites and then run Grunt to
perform the upgrade. All of the configuration (including user
management) is handled by Puppet.

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
