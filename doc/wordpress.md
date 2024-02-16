# WordPress

We run two quite different types of WordPress installations:

* The `blogs` servers host blog.jquery.com, blog.jqueryui.com and
  blog.jquerymobile.com. These are edited directly via the WordPress
  admin interface by humans who log in with their own accounts.
* The `docs` sites host everything else. This is a collection of
  about 20 sites that are automatically provisioned from Git
  repositories using the [grunt-jquery-content] system.

[jquery-wp-content]: https://github.com/jquery/grunt-jquery-content/

All sites have their WordPress settings managed by Puppet, and all
sites are powered by a locally running MariaDB instance, and backed
up daily to Tarsnap.

## WordPress versions

WordPress "auto upgrades" are enabled. If you want to pin
a specific version or rollback to an older version, set one of these
hiera keys in `common.yaml` to the version you want to use:

```yaml
profile::wordpress::blogs::wordpress_version: ''
profile::wordpress::docs::wordpress_version: ''
```

You might also need to restore the database from a backup if the
older version had a different database schema.

## Doc sites

### Builder hosts

The docs sites are provisioned by the `builder` hosts. These run
`node-notifier` to pick up changes to the sites and then run Grunt to
perform the upgrade. All of the configuration (including user
management) is handled by Puppet.

### Control flow

1. Each doc site has an associated Git repository, such as [api.jquery.com](https://github.com/jquery/api.jquery.com/).
2. An [organization-wide webhook](https://github.com/organizations/jquery/settings/hooks/) notifies the `builder` and `wp` hosts of commits and published tags. The hooks are secured with secret tokens and SSL-verification.
3. The `builder` hosts are provisioned with `role::docs::builder` by Puppet. Sites are defined by `docs_sites` in [hieradata/common.yaml](../hieradata/common.yaml). The builder host uses [jquery/notifier](https://github.com/jquery/node-notifier-server/) to receive these hooks. In the staging environment, sites generally build on each commit to the main branch. In production, most sites react only to semver-formatted tags.
4. Upon a relevant commit or tag, a [shell script](../modules/profile/files/builder/builder-do-update.sh) is executed on the builder host, which checks out the relevant commit hash, and uses `grunt-jquery-content` to build the WordPress pages, and deployes them via WordPress RPC to the `wp` hosts.
5. The `wp` hosts contain several standalone WordPress installations (Nginx, php-fpm, MariaDB). Our themes and plugins are managed in the [jquery-wp-content.git](https://github.com/jquery/jquery-wp-content) repository. Changes to jquery-wp-content are automatically deployed on every main branch commit, to both production and staging wp hosts.
6. The CDN for most doc sites is Cloudflare, except for releases.jquery.com which is behind Fastly (matching code.jquery.com). See also [cdn.md](./cdn.md).

### Debugging builder notifier

To check for any system problems with the notifier that receives webhooks, or the shell script that builds and deploys the site, ssh to a builder host, and run the following command:

```bash
# Staging    : ssh builder-XX.stage.ops.jquery.net
# Production : ssh builder-XX.ops.jquery.net

$ sudo journalctl -u notifier -f -n100

```

### Manual build

```bash
$ ssh builder-XX.stage.ops.jquery.net
$ cd /srv/builder/jquerymobile_com/
$ sudo -u builder git log -1

$ sudo -u builder builder-do-update /srv/builder/jquerymobile_com/

# …
# node_modules/.bin/grunt deploy
# …
# Running "build-posts:page" (build-posts) task
# …
# Running "wordpress-validate" task
# …
# Running "wordpress-sync" task
# …
```

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

## Backups

We keep Tarsnap backups for the databases and (for blogs) uploads. See
the [backup.md] file for details.

[backup.md]: ./backup.md
