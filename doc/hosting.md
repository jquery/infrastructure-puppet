# Hosting

Nodes managed by this Puppet repository are hosted at **DigitalOcean**.

* Management: <https://cloud.digitalocean.com/>
* Access
  * jQuery Infra Team members
  * LF IT via <https://support.linuxfoundation.org>

## Create a new node

* Region:
  * Default: NYC3 (`nyc3-vpc-openjsf1`)
  * Secondary: SFO3 (`default-sfo3`)
  * Most servers should use **NYC3**. For critical services (like wp-xx) that have 2+ interchangeable servers (all servers can serve all websites), we also put one server in SFO3 for increased resilience, allowing us to switch traffic there if needed.
* Image: Debian (latest LTS).
* Plan:
  * When replacing an existing server match the plan of the old one, unless a spec change is part of the replacement. To see the full spec of an existing server, select it from the "Droplets" list, go to "Resize", and scroll to the highlighted row.
  * For new servers, we typically use a small dual-core plan unless more is needed, such as:
    * Shared CPU > Basic > Regular Intel > 2 CPUs 2GB RAM ($18/month in 2022)
    * Shared CPU > Basic > Regular Intel > 2 CPUs 4GB RAM ($24/month in 2022)
* Backups:
  * **Enable** for **puppetserver**, **wpblogs**, and **contentorigin** servers that are in "production", because those are stateful and harder to recreate and recover from Tarsnap backups alone.
  * For most servers we leave this off to reduce sponsorship cost, and because they are either not critical (stage servers) or easy to recreate (self-provisioning via Puppet, no state).
* Authentication: **SSH**. Add yourself and 1 team mate for initial bootstrapping. These will be replaced by Puppet later.
* Additional options:
  * Enable "Monitoring" (free)
* Advanced options:
  * Enable "IPv6" (free)
* Hostname: Refer to [dns.md](./dns.md)
  * Pick the next number within the given role and realm.
* Tags:
  * For production hosts, enter one of `jquery-prod-1cpu`, `jquery-prod-2cpu` or `jquery-prod-4cpu`
  * For stage hosts, leave empty.
  * This is used by Monitoring Alerts that email us on prolonged high server load. We prefer the load-average metric over CPU-utilization, and unfortunately that means the alert threshold varies by CPU count (match the selected plan).

Once the droplet has been created:

1. Define the chosen hostname with the allocated IP in DNS,
   * Cloudflare Dashboard > jquery.net zone > DNS
   * Create A record
   * Proxy status: Off

2. If the droplet may upload to Tarsnap (roles: wp, wpblogs, puppet, filestash, contentorigin)
   then grant the host access to Tarsnap by running this command **from the Puppet server**. See also [Backup § Host management](./backup.md#host-management.md).

   ```shell-session
   puppet-00$ jq-tarsnap-keygen EXAMPLE.ops.jquery.net
   ```

   Without this, Puppet will fail as follows:
   ```
   Error: Could not retrieve catalog from remote server: Error 500 on SERVER: …
   Could not find any files from /srv/git/puppet/private/files/tarsnap-keys/example-01.ops.jquery.net.key
   ```

3. Follow [Puppet § Provisioning new nodes](./puppet.md).

## Delete a node

Prior to deleting a production node, it is recommended to first deprecate it:

* Turn off the droplet in DigitalOcean.
* Update or remove any GitHub webhooks that may point to this host.
* Update or remove any references in Cloudflare DNS or Puppet to this host (apart from the definition in Puppet `site.pp` and DNS `jquery.net`).
* Update or remove any references in Fastly service origins.

Once ready to permanently delete a node:

* Follow [Puppet § Decommissioning nodes](./puppet.md).
* Delete the droplet in DigitalOcean.
* Delete the record from the jquery.net zone in DNS.

## Migrating a node

Before beginning a fleet-wide Debian upgrade, ensure [Puppet § Adding a new Debian version](./puppet.md#adding-a-new-debian-version) has been done for version in question. For an example ofa fleet-wide node migration, see https://github.com/jquery/infrastructure-puppet/issues/37.

### Register a webhook

When adding nodes to webhooks, whether org-wide or a single repo:

* set `https://FQDN_HERE:8333/` as the URL,
* choose `application/json` as content type,
* and use the secret from `ssh puppet-04.ops.jquery.net git -C /srv/git/puppet/private grep webhook_secret` for production or staging respectively,
* confirm in the GitHub UI that the `ping` payload was succesfully delivered

### builder

* Follow [§ Create a new node](#create-a-new-node) for `builder-XX` and `builder-XX.stage`
* Follow [§ Register a webhook](#register-a-webhook) for the new nodes at [org-wide jquery webhooks](https://github.com/organizations/jquery/settings/hooks)

At this point, any commits or tags in docsite repos notify both the new and old builder nodes, with both performing the same builds, and both racing to write pages to the wpdocs nodes. This should be fine as the updates are idempotent, however it is recommended to shutdown the old builder nodes at this point so that we excercise them fully and discover potential issues. These nodes are not user-facing and idle most of the time.

After one or two docsites have succesfully used the new builder (see [wordpress.md](./wordpress.md)):

* Remove old nodes from [jquery org-wide webhooks](https://github.com/organizations/jquery/settings/hooks)
* Follow [§ Delete a node](#delete-a-node) for the old nodes

### codeorigin

* Follow [§ Create a new node](#create-a-new-node) for `codeorigin-XX` and `codeorigin-XX.stage`
* Follow [§ Register a webhook](#register-a-webhook) for the new node at [jquery/codeorigin](https://github.com/jquery/codeorigin.jquery.com/settings/hooks)
* Verify that [CodeoriginTest.php](../test/CodeoriginTest.php) passes for both of the new nodes
* Change `test-codeorigin-stage` in [Makefile](../Makefile) to monitor the new stage node instead
* Switch "code2" service in Fastly to the new prod node
* Switch "code" service in Fastly to the new prod node
* Remove old nodes from [jquery/codeorigin webhooks](https://github.com/jquery/codeorigin.jquery.com/settings/hooks)
* Shutdown the old nodes and **wait a few days** to ease recovery just in case
* Follow [§ Delete a node](#delete-a-node) for the old nodes

### contentorigin

* Follow [§ Create a new node](#create-a-new-node) for `contentorigin-XX`
* Restore the latest `wordpress` and `mariadb` archives from Tarsnap to the new node,
  by running the `bin/restore-tarsnap.sh` script in this repo from your machine.

  ```sh
  bin/restore-tarsnap.sh list contentorigin-OLD.ops.jquery.net
  # ...

  bin/restore-tarsnap.sh restore contentorigin-OLD.ops.jquery.net contentorigin-SOME_DATE contentorigin-XX.example.net
  ```
* Move /var/www into place:
  ```sh
  rmdir /srv/www/content.jquery.com

  cd /root/restored_from_tarsnap/OLD_NODE__contentorigin_SOME_DATE/srv/www
  sudo mv -Tn content.jquery.com /srv/www/content.jquery.com
  sudo mv -Tn static.jquery.com /srv/www/static.jquery.com
  ```
* Verify that these tests now pass:
  ```sh
  php tests/ContentoriginTest.php contentorigin-XX.ops.jquery.net
  ```
* Switch "content" service in Fastly to the new node and test https://content.jquery.com responds fine
* Shutdown the old nodes and **wait a few days** to preserve prior backups and ease recovery just in case
* Follow [§ Delete a node](#delete-a-node) for the old node

### filestash (docs::filestash)

> [!WARNING]
> TODO: Document this

### gruntjs (gruntjscom)

* Follow [§ Create a new node](#create-a-new-node) for `gruntjs-XX`
* Follow [§ Register a webhook](#register-a-webhook) for the new node at [gruntjs/gruntjs.com webhooks](https://github.com/gruntjs/gruntjs.com/settings/hooks)
* Test that the website works via the instance's own address, e.g. `https://gruntjs-XX.ops.jquery.net`
* Switch DNS for `gruntjs.com`
* Follow [§ Delete a node](#delete-a-node) for the old node
* Remove old node from [gruntjs/gruntjs.com webhooks](https://github.com/gruntjs/gruntjs.com/settings/hooks)

### miscweb

* Follow [§ Create a new node](#create-a-new-node) for `miscweb-XX`
* Temporarily set the following overrides via a `/hieradata/nodes/` file. This disables certbot for the miscweb-sites and miscweb-redirects domains, which would otherwise fail (because those don't point here yet in DNS) and would prevent the server from provisioning succesfully.
  ```yaml
  profile::certbot::certificates:
    miscweb-fqdn:
      domains:
        - "%{::facts.networking.fqdn}"
  profile::miscweb::default_certificate: miscweb-fqdn
  profile::miscweb::redirects: {}
  ```
* Follow [§ Register a webhook](#register-a-webhook) for the new node at [org-wide jquery webhooks](https://github.com/organizations/jquery/settings/hooks)
* Test that the instance responds over HTTPS with a redirect to jquery.com, e.g. `https://miscweb-XX.ops.jquery.net`
* Switch "miscweb" service in Fastly to the new node and test https://podcast.jquery.com responds fine
* Switch miscweb-redirects and miscweb-sites traffic:
  - Switch DNS for `miscweb-redirects.svc.jquery.net` and `miscweb-sites.svc.jquery.net` (HTTPS will fail until the next steps are complete)
  - Remove `/hieradata/nodes/` file for the new miscweb node. Commit, push to staging+production, and `sudo run-puppet-agent` on the new miscweb node
  - Test that redirects work fine by running `make test` in this repo
  - Test that https://bugs.jquery.com/ticket/7144 and https://themeroller.jquerymobile.com/ respond fine
* Remove old node from [jquery org-wide webhooks](https://github.com/organizations/jquery/settings/hooks)
* Follow [§ Delete a node](#delete-a-node) for the old node

### puppet

> [!WARNING]
> TODO: Document the rest of this

* Follow [§ Register a webhook](#register-a-webhook) for the new node at [jquery/infrastructure-puppet webhooks](https://github.com/jquery/infrastructure-puppet/settings/hooks)
* Remove old node from [jquery/infrastructure-puppet webhooks](https://github.com/jquery/infrastructure-puppet/settings/hooks)

### search

* Follow [§ Create a new node](#create-a-new-node) for `search-XX`
* Follow [Search § Setup a new server](./search.md#setup-a-new-server) and refer to [how we tested it](https://github.com/jquery/infrastructure-puppet/issues/37#issuecomment-4598860788)
* Follow [§ Delete a node](#delete-a-node) for the old nodes

### wpdocs

Staging:
* Follow [§ Create a new node](#create-a-new-node) for `wp-XX.stage`,
  including the special step to run `jq-tarsnap-keygen` before provisioning with Puppet.
* Switch DNS for `wpdocs-stage.svc.jquery.net`. This is done first instead of last, as otherwise the instance cannot acquire [TLS certificates](../hieradata/environments/staging/roles/docs/wordpress.yaml). For production we proxy via Cloudflare or Fastly and require only a FQDN certificate on the origin.
* NOTE: Puppet automatically updates [builder nodes](#builder) to be aware of all wpdocs hosts. This means the builder logs is expected to temporarily contain errors if it tries to push content to a new node before it was ready.
* Follow [§ Register a webhook](#register-a-webhook) for the new node at [org-wide jquery webhooks](https://github.com/organizations/jquery/settings/hooks).
* Once provisioned, check that https://stage.api.jquery.com/ renders OK (albeit empty, with no pages yet).
* ssh to a **staging** builder:
  * Confirm `cat /etc/builder-wordpress-hosts` contains the new wp-XX.stage host.
  * Run `builder-rebuild-all` and wait for it to finish (~20min).
    If any issues come up, fix those first. You can iterate on a single site with [WordPress § Manual build](./wordpress.md#manual-build). When you push a commit to the site's repo, the webhook automatically starts a build. You can follow use [WordPress § Debug notifier](./wordpress.md#debug-notifier) to follow this.
  * Spot-check these staging sites and confirm that they look the same as their production counterparts:
    * https://stage.jquery.com/
    * https://stage.api.jquery.com/
    * https://stage.api.jqueryui.com/1.13/
    * https://stage.api.jquerymobile.com/
    * https://stage.releases.jquery.com/
    * https://stage.releases.jquery.com/git/jquery-git.js
* Remove old node from [jquery org-wide webhooks](https://github.com/organizations/jquery/settings/hooks)
* Follow [§ Delete a node](#delete-a-node) for the old node

Production:
* Follow [§ Create a new node](#create-a-new-node) for two `wp-XX` instances, including these special steps:
  * **create the second wp-XX instance in the SFO3 region** instead of the default NYC3 region.
  * run `jq-tarsnap-keygen` for both new node names, before provisioning with Puppet.
* Once provisioned, ssh to each of the new wp hosts and confirm that these requests respond with HTTP 200, and the expected title.
  ```sh
  curl -si https://$(hostname -f) -H 'Host: jquery.com' | head -n 25
  curl -si https://$(hostname -f) -H 'Host: jqueryui.com' | head -n 25
  # HTTP/1.1 200 OK
  # …
  # <title>jQuery</title>
  # …
  # <title>jQuery UI</title>
  ```
* ssh to a **production** builder:
  * Confirm `cat /etc/builder-wordpress-hosts` contains both of the new wp-XX hosts.
  * Run `builder-rebuild-all` and wait for it to finish (~20min).
    * If any issues come up, fix those first. You can iterate on a single site with [WordPress § Manual build](./wordpress.md#manual-build). When you push a commit to the site's repo (and a semver tag for sites that require this), the webhook automatically starts a build. You can follow use [WordPress § Debug notifier](./wordpress.md#debug-notifier) to follow this.
    * Once all issues are fixed, re-run `builder-rebuild-all`
* Switch DNS for https://api.jquerymobile.com/ and confirm that it looks the same as before.
   Wait for and confirm that it is a response from a new server by comparing the `X-Powered-By: PHP/X.Y.Z` version in browser devtools.
* Switch DNS for all sites listed at [WordPress § Doc sites](./wordpress.md#doc-sites).
  We assign `*.jquery.com` to the first node (NYC),
  and assign all others to the second node (SFO).
* Switch "releases" service in Fastly and change both origins to the new hosts.
  Take care to update all mentions of the hostname in the origin settings (origin name, origin address, expected cert, expected SNI).
  Browse around https://releases.jquery.com until you see a response with the newer `X-Powered-By: PHP/X.Y.Z` version in broser devtools. If this doesn't happen, perhaps check the origin? See also [Runbook: Nginx debugging](./runbook-nginx-debug.md).
  ```sh
  curl -si https://wp-XX.ops.jquery.net/jquery/ -H 'Host: releases.jquery.com' | head -n25
  # HTTP/1.1 200 OK
  # …
  # <title>jQuery Core &#8211; All Versions | jQuery CDN</title>
  # …
  ```
* Shutdown the old nodes and **wait a few days** to preserve prior backups and ease recovery just in case
* Remove old node from [jquery org-wide webhooks](https://github.com/organizations/jquery/settings/hooks)
* Follow [§ Delete a node](#delete-a-node) for the old node

### wpblogs

* Follow [§ Create a new node](#create-a-new-node) for `wpblogs-XX`
* Follow [§ Register a webhook](#register-a-webhook) for the new node at [org-wide jquery webhooks](https://github.com/organizations/jquery/settings/hooks)
* Once the new node is provisioned, verify each site is working:
  ```sh
  curl -i https://wpblogs-XX.ops.jquery.net -H 'Host: blog.jquery.com' -s | grep -iE 'HTTP/|server:|powered-by:|<title'
  curl -i https://wpblogs-XX.ops.jquery.net -H 'Host: blog.jqueryui.com' -s | grep -iE 'HTTP/|server:|powered-by:|<title'
  curl -i https://wpblogs-XX.ops.jquery.net -H 'Host: blog.jquerymobile.com' -s | grep -iE 'HTTP/|server:|powered-by:|<title'
  # HTTP/1.1 200 OK
  # <title>Official jQuery Blog</title>
  # …
  # <title>jQuery UI Blog</title>
  # …
  # <title>jQuery Mobile Blog</title>
  ```
* Restore the latest `wordpress` and `mariadb` archives from Tarsnap to the new node,
  by running the `bin/restore-tarsnap.sh` script in this repo from your machine.

  ```sh
  bin/restore-tarsnap.sh list wpblogs-OLD.example.net
  # ...

  bin/restore-tarsnap.sh restore wpblogs-OLD.example.net wordpress-SOME_DATE wpblogs-XX.example.net
  ```
* Move wp-content archive into place for each site (the `rm` is needed because WordPress creates empty directories for several recent years and months).
  ```sh
  sudo rm -rf /srv/wordpress/sites/jquery/wp-content/uploads
  sudo rm -rf /srv/wordpress/sites/jqueryui/wp-content/uploads
  sudo rm -rf /srv/wordpress/sites/jquerymobile/wp-content/uploads

  cd /root/restored_from_tarsnap/OLD_NODE__wordpress_SOME_DATE/var/wordpress/sites
  sudo mv -Tn jquery/wp-content/uploads /srv/wordpress/sites/jquery/wp-content/uploads
  sudo mv -Tn jqueryui/wp-content/uploads /srv/wordpress/sites/jqueryui/wp-content/uploads
  sudo mv -Tn jquerymobile/wp-content/uploads /srv/wordpress/sites/jquerymobile/wp-content/uploads
  ```
* Import the databases.
  ```sh
  cd /root/restored_from_tarsnap/OLD_NODE__mariadb_SOME_DATE/var/lib/backup/mariadb
  sudo mysql wordpress_jquery < wordpress_jquery.sql;
  sudo mysql wordpress_jqueryui < wordpress_jqueryui.sql;
  sudo mysql wordpress_jquerymobile < wordpress_jquerymobile.sql;
  ```
* Tests for specific old posts should now pass:
  ```sh
  php tests/WpblogsTest.php wpblogs-XX.ops.jquery.net
  ```
* Switch DNS for:
  - `blog.jquery.com`
  - `blog.jqueryui.com`
  - `blog.jquerymobile.com`
* Log into wp-admin in your browser on one of the sites to
  verify that user accounts work fine, and there are no warnings/errors reported there.
* Shutdown the old node and **wait a few days** to ease recovery just in case
* Remove old nodes from [jquery org-wide webhooks](https://github.com/organizations/jquery/settings/hooks)
* Follow [§ Delete a node](#delete-a-node) for the old node
