# jQuery CDN

## Services

Primary services:
* `code.jquery.com` HTTP + HTTPS
* `releases.jquery.com` HTTP + HTTPS

Legacy services:
* `content.jquery.com` HTTP + HTTPS
* `static.jquery.com` HTTP + HTTPS (alias: content)
* `codeorigin.jquery.com` HTTP + HTTPS (alias: code)
* `content.origin.jquery.com` HTTP only (alias: content)
* `static.origin.jquery.com` HTTP only (alias: content)

## Service: code.jquery.com

As of January 2023, jQuery CDN transfers 2.2 petabytes a month in bandwidth. jQuery CDN is currently powered by StackPath ([§ History](#history)).

StackPath is configured to consider content at any URL to be immutable. New content is pulled by the CDN from our origin server.

The origin servers (hosted at DigitalOcean) are managed by Puppet, running Debian Linux with an Nginx web server to serve static files. Files are served from a checkout of the [codeorigin Git repository](https://github.com/jquery/codeorigin.jquery.com).

New files are automatically pushed to origin servers through a webhook (using [jquery/node-notifier-server](https://github.com/jquery/node-notifier-server)).

### Performance and security

The following are examples of mitigations and optimizations:

* Consumers: Promote use of SRI integrity attributes on `<script>` tags.
* CDN: 2FA for control panel accounts.
* CDN: Gzip compression and 1-year unconditional browser caching.
* CDN: Pull from origin using an encrypted connection (including for plain HTTP requests).
* CDN: Enable strict SNI verification on the HTTPS/TLS connection to the origin.
* Origin: Debian Linux LTS with debian-security, unattended-upgrades, and basic firewalls.
* Origin: Nginx, Certbox, and Node installed from upstream Debian (no custom apt repo, PPA, or unpackaged software).
* Origin: Require webhook payloads from GitHub to carry an HMAC-verified signature, based on a secret token.
* Origin: Require commits from GitHub to be fast-forward only (webhook handler rejects other commits).
* Origin: [node-notifier](https://github.com/jquery/node-notifier-server) written with minimal dependencies, using only pinned versions of well-known and audited npm dependencies, which themselves have no transitive dependencies.
* Git: 2FA for org owners and teams with CDN access (Infrastructure team, Release team).
* Git: Ensure [reproducible builds](https://reproducible-builds.org/) for release artefacts ([QUnit: Done](https://github.com/qunitjs/qunit/actions/workflows/reproducible.yaml), jQuery: Work in progress).

### Testing and monitoring

The staging server at `https://codeorigin-02.stage.ops.jquery.net` can be used to validate server configuration changes before production deployment. For example, the equivalent of <https://code.jquery.com/color/jquery.color.svg-names-2.0.0.min.js> is also served from `https://codeorigin-02.stage.ops.jquery.net/color/jquery.color.svg-names-2.0.0.min.js`.

You can run [an automated test suite](https://github.com/jquery/codeorigin.jquery.com/tree/main/test) against either the production or staging server.

For uptime monitoring, refer to [monitoring.md](./monitoring.md).

### Highwinds configuration

In StrikeTracker (StackPath Highwinds' control panel), the "code" site has the following notable configuration settings:

* SSL support: Enabled.
* IPv6 support: Enabled.
* HTTPS/2 support: Enabled.
* Delivery:
  * Gzip compression: Enabled.
  * Gzip level: 6 (highest).
* Cache overrides:
  * Browser TTL: 1 year (max-age=31536000)
  * CDN TTL: 1 year (max-age=31536000)
  * Stale Cache Extension: 1 day (86400 seconds)
  * Case Insensitive Cache: Enabled.
* Origin:
  * No Query String Parameters: Enabled.
  * Origin protocol: Always HTTPS.
  * Compressed Origin Pull: Enabled (accept Gzip responses).
* Reporting:
  * Raw Logs: **Disabled**.
  * Access Log: **Disabled**.
  * Origin Log: **Disabled**.

See also:

* [StrikeTracker Help - Origins](https://support.highwinds.com/hc/en-us/articles/360029757491-Origins)
* [StrikeTracker Help - Origin Settings](https://support.highwinds.com/hc/en-us/articles/11299302193563-Origin-Settings)

## Service: release.jquery.com

This is a WordPress-based documentation site (see TODO), similar to https://jquery.com and https://api.jquery.com.

Notable differences:

* support access over IPv6
* support access over plain HTTP (no redirect)
* no traffic rejection of any kind (e.g. DDOS/WAF or other security rules)
* served by jQuery CDN (unlike other doc sites, which use Cloudflare)
* proxy `/git/` directory to serve unreleased alpha versions, built by Jenkins

## Service: content.jquery.com

The content CDN hosts legacy media content. It hosts the canonical audio files for the [jQuery Podcast](https://podcast.jquery.com/) as referenced in the Apple Podcasts directory and indexed by major podcast apps. The service also hosts various other binary files, such as videos (historical conference talks) and miscellaneous images, as referenced in blog posts and other web content.

## History

In 2008, jQuery CDN was transferring 50 GB per day in bandwidth, estimated at [2 TB per month](https://blog.jquery.com/2008/11/19/cloudfront-cdn-for-jquery/). At the time, the service was hosted using Amazon CloudFront (not sponsored).

In 2013, [MaxCDN joined jQuery Foundation](https://blog.jquery.com/2014/01/14/jquerys-content-delivery-network-you-got-served/) as [platinum member](https://web.archive.org/web/20150212105155/jquery.org/members/). MaxCDN became the first sponsor of jQuery CDN, backed by NetDNA Enterprise. Among other things, this brought [support for HTTPS](https://blog.jquery.com/2014/01/13/the-state-of-jquery-2014/) to jQuery CDN. NetDNA rebranded as MaxCDN later that year.

By January 2014, jQuery CDN transferred over 3.6 petabytes in a five-month period, about [720 terabytes per month](https://blog.jquery.com/2014/01/14/jquerys-content-delivery-network-you-got-served/) on average. We reported data transfers of 11 petabytes for the year 2014, over [900 terabytes per month](https://blog.jquery.com/2015/02/11/jquery-foundation-2014-annual-report/) on average.

In 2018, jQuery CDN internally [transitioned from MaxCDN to Highwinds](https://www.stackpath.com/blog/maxcdn-and-securecdn-are-retiring-heres-what-it-means-for-you/), after StackPath [acquired MaxCDN](https://web.archive.org/web/20180309211017/https://www.maxcdn.com/blog/maxcdn-joins-stackpath/) in 2016, and [acquired Highwinds](https://www.stackpath.com/blog/highwinds-joins-stackpath/) in 2017.

By 2021, our traffic had risen to [over 2 petabytes](https://blog.jquery.com/2021/06/17/jquery-project-updates-addressing-temporary-cdn-issues/) per month.

### Latest statistics

As of January 2023, jQuery CDN transfers 2.2 petabytes a month in bandwidth, in response to 57 billion web requests, with a cache-hit ratio of >99.999%.

jQuery is used by [73% of the top 100K websites](https://trends.builtwith.com/javascript/jQuery) according to BuiltWith as of June 2023. According to W3 Techs in July 2023, jQuery is used on [77% of the world's top 10 million websites](https://w3techs.com/technologies/details/js-jquery). jQuery is used on [94% of websites](https://w3techs.com/technologies/details/js-jquery) that use at least one known JavaScript library.

jQuery CDN is the [4th largest](https://w3techs.com/technologies/overview/content_delivery) JavaScript content delivery network, used by [17.5% of websites](https://w3techs.com/technologies/details/cd-jquerycdn) that use a known CDN for loading JavaScript content, and 5% of all websites globally (according to W3 Techs in July 2023).

## See also

* [Reduce risk around code.jquery.com CDN](https://github.com/jquery/infrastructure/issues/474) (2020-2022), Timo Tijhof, GitHub Issues (restricted).
* [code.jquery.com migration plan](https://docs.google.com/document/d/1olYuJFuBy4gkBE0TY6dxdYCsL5b1p2jBIbksE9TzWqg/edit) (2020), Brian Warner, Google Docs (restricted).