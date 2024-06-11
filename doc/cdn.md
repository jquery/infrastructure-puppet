# jQuery CDN

## Services

Primary services:
* `code.jquery.com` HTTP + HTTPS
* `releases.jquery.com` HTTP + HTTPS
* `content.jquery.com` HTTP + HTTPS

Legacy services:
* `codeorigin.jquery.com` HTTP + HTTPS (alias: code)
* `static.jquery.com` HTTP + HTTPS (alias: content)
* `content.origin.jquery.com` HTTP only (alias: content)
* `static.origin.jquery.com` HTTP only (alias: content)

## Service: code.jquery.com

As of January 2023, jQuery CDN transfers 2.2 petabytes a month in bandwidth. jQuery CDN is currently powered by Fastly ([§ History](#history)).

Fastly is configured to treat content as immutable (cached unconditionally for up to 1 year). New content is pulled by the CDN from an origin server.

The origin servers (hosted at DigitalOcean) are managed by Puppet, running Debian Linux with an Nginx web server to serve static files. Files are served from a checkout of the [codeorigin Git repository](https://github.com/jquery/codeorigin.jquery.com).

New files are automatically pushed to origin servers through a webhook (using [jquery/node-notifier-server](https://github.com/jquery/node-notifier-server)).

### Performance and security

The following are examples of mitigations and optimizations:

* Consumers: Promote use of SRI integrity attributes on `<script>` tags.
* CDN: 2FA for control panel accounts.
* CDN: Gzip compression, 1-year unconditional browser caching, 7-day stale-while-revalidate.
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

### Fastly configuration

The "code" service has the following notable configuration settings (last updated Oct 2023). See also [issue #30](https://github.com/jquery/infrastructure-puppet/issues/30).

* Origins:
  * Always TLS to origin.
  * Verify cert.
  * Enable SNI hostname.
* Headers
  * [Ignore query strings: req.url = req.url.path](https://docs.fastly.com/en/guides/making-query-strings-agnostic)
  * [Case-insensitive req.url](https://developer.fastly.com/reference/vcl/functions/strings/std-tolower/)
* DNS entrypoint:
  * Dualstack IPv4 & IPv6.
  * TLS 1.2+
  * TLS ciphers include CBC (for Windows 7, Windows 8, and IE9-11 compat).
  * HTTP/2
  * HTTPS & plain HTTP

## Service: release.jquery.com

This is a WordPress-based documentation site (see [wordpress.md](./wordpress.md)), similar to https://jquery.com and https://api.jquery.com and served from the same set of WordPress origin servers.

The `releases.jquery.com` domain has additional Nginx configuration to proxy the `/git` directory from the `filestash` server.

Notable differences:

* fronted by same CDN provider as the jQuery CDN (unlike our other doc sites, which use Cloudflare).
* support access over IPv6.
* support access over plain HTTP (no redirect).
* little to no traffic filtering (e.g. DDOS/WAF or other security rules, no captchas, interstitials, or other client-side interventions).

## Service: content.jquery.com

The content CDN hosts media content. It hosts the canonical audio files for the [jQuery Podcast](https://podcast.jquery.com/) as referenced in the Apple Podcasts directory and indexed by major podcast apps.

The service also hosts various other binary files, such as videos (historical conference talks) and miscellaneous images, as referenced in blog posts and other web content.

## History

In 2008, jQuery CDN was transferring 50 GB per day in bandwidth, estimated at [2 TB per month](https://blog.jquery.com/2008/11/19/cloudfront-cdn-for-jquery/). At the time, the service was hosted using Amazon CloudFront (not sponsored).

In 2013, [MaxCDN joined jQuery Foundation](https://blog.jquery.com/2014/01/14/jquerys-content-delivery-network-you-got-served/) as [platinum member](https://web.archive.org/web/20150212105155/jquery.org/members/). MaxCDN became the first sponsor of jQuery CDN, backed by NetDNA Enterprise. Among other things, this brought [support for HTTPS](https://blog.jquery.com/2014/01/13/the-state-of-jquery-2014/) to jQuery CDN. NetDNA rebranded as MaxCDN later that year.

By January 2014, jQuery CDN transferred over 3.6 petabytes in a five-month period, about [720 terabytes per month](https://blog.jquery.com/2014/01/14/jquerys-content-delivery-network-you-got-served/) on average. We reported data transfers of 11 petabytes for the year 2014, over [900 terabytes per month](https://blog.jquery.com/2015/02/11/jquery-foundation-2014-annual-report/) on average.

In 2018, jQuery CDN internally [transitioned from MaxCDN to Highwinds](https://www.stackpath.com/blog/maxcdn-and-securecdn-are-retiring-heres-what-it-means-for-you/), after StackPath [acquired MaxCDN](https://web.archive.org/web/20180309211017/https://www.maxcdn.com/blog/maxcdn-joins-stackpath/) in 2016, and [acquired Highwinds](https://www.stackpath.com/blog/highwinds-joins-stackpath/) in 2017.

By 2021, our traffic had risen to [over 2 petabytes](https://blog.jquery.com/2021/06/17/jquery-project-updates-addressing-temporary-cdn-issues/) per month.

In 2023, jQuery CDN [migrated](https://github.com/jquery/infrastructure-puppet/issues/30) from StackPath to Fastly.

### Latest statistics

Traffic profile as of January 2023 ("code" and "releases" services combined):

* Overall: 2.2 petabytes bandwidth per month, in response to 57 billion web requests.
* 16K-30K req/s (mean: 21K req/s)
* Bandwidth: 4.7-8.9Gbps (mean: 6.2Gbps)
* Average response size: 39KB
* Cache-hit ratio: >99.999%
* Library size: 398MB ([codeorigin.git](https://github.com/jquery/codeorigin.jquery.com))
* Geographic distribution (HTTPS): US-West (4 POPs): 24%, US-East (7 POPs): 19%, US-Central (3 POPs): 8%, Europe (11 POPs): 49%.
* Geographic distribution (HTTP): US-West: 41%, US-East: 7%, US-Central: 4%, Europe: 48%.

jQuery is used by [73% of the top 100K websites](https://trends.builtwith.com/javascript/jQuery) according to BuiltWith as of June 2023. According to W3 Techs in July 2023, jQuery is used on [77% of the world's top 10 million websites](https://w3techs.com/technologies/details/js-jquery). jQuery is used on [94% of websites](https://w3techs.com/technologies/details/js-jquery) that use at least one known JavaScript library.

jQuery CDN is the [4th largest](https://w3techs.com/technologies/overview/content_delivery) JavaScript content delivery network, used by [17.5% of websites](https://w3techs.com/technologies/details/cd-jquerycdn) that use a known CDN for loading JavaScript content, and 5% of all websites globally (according to W3 Techs in July 2023).

## See also

* [Reduce risk around code.jquery.com CDN](https://github.com/jquery/infrastructure/issues/474) (2020-2022), Timo Tijhof, GitHub Issues (restricted).
* [code.jquery.com migration plan](https://docs.google.com/document/d/1olYuJFuBy4gkBE0TY6dxdYCsL5b1p2jBIbksE9TzWqg/edit) (2020), Brian Warner, Google Docs (restricted).
