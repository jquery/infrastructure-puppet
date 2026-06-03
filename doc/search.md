# Search

As of 2023, we use multiple different search solutions.

## WordPress

The WordPress-based sites (blogs like https://blog.jquery.com, documentation
sites like https://api.jquery.com, and misc sites like https://brand.jquery.org
or https://learn.jquery.com) use either the default MySQL-based search backend
that comes with WordPress, or the [Relevanssi plugin for WordPress](https://wordpress.org/plugins/relevanssi/)
that improves its result quality and performance in a way that is transparent
to the WordPress theme and frontend.

The plugin installation and configuration resides in the
<https://github.com/jquery/jquery-wp-content> repository.

## Typesense

### Background

In 2021, we looked for an open-source solution that we can support within the free software ecosystem. In doing so we aimed to increase security and availability (by reducing client-side dependence on third-party domains), and lower our privacy budget.

We first evaluated Meilisearch ([private thread](https://github.com/jquery/infrastructure/issues/522)) but found it suboptimal technically (difficult upgrades, not yet committing to forward compatibility or automatic in-place upgrades), [opt-out telemetry](https://docs.meilisearch.com/learn/what_is_meilisearch/telemetry.html) instead of opt-in, no official Debian packages, non-trivial interactive setup, missing support for querying multiple indexes such as jquery.com and api.jquery.com), and with unclear future in terms of business model (Meilisearch Cloud was not yet in the picture, and the backend is not GPL licensed).

In 2022, we adopted [Typesense](https://typesense.org/) for all documentation sites.

### Runbook

* Canonical domain: https://typesense.jquery.com

#### Read TYPESENSE_BOOTSTRAP_KEY

Read from `profile::typesense::api_key` in [Private Hiera data](./puppet.md).

#### Generate admin keys

For security reason, we don't use the "bootstrap" admin API key beyond internal provisioning
and minting other API keys. If you need an admin key for anything outside Puppet, such as for
a CI job that crawls a site and uploads content to Typesense, then generate a key for that
one website (or for a group of related sites under the same project/owner).

Remember to set a collection prefix, and put the project name in the description.

You can either let a random key be generated, or ensure the existence of a
given API key by setting the `value` key in the posted JSON message.

https://typesense.org/docs/0.24.0/api/api-keys.html

```
export TYPESENSE_BOOTSTRAP_KEY=...

# Create admin key for qunitjs_com and other qunit* collections.
curl http://localhost:8108/keys \
  -X POST \
  -H "X-TYPESENSE-API-KEY: $TYPESENSE_BOOTSTRAP_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"description":"QUnit admin key.","actions": ["*"], "collections": ["qunit.*"]}'
```

#### Generate public search-only key

"Seach-only" keys are for public use in browsers and other clients, and may
be committed to public Git repositories. Use the below command from
the `search` backend server to generate such keys.

```
export TYPESENSE_BOOTSTRAP_KEY=...

curl http://localhost:8108/keys \
  -X POST \
  -H "X-TYPESENSE-API-KEY: $TYPESENSE_BOOTSTRAP_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"description":"Search-only key.","actions": ["documents:search"], "collections": ["*"]}'
```

#### Add public search-only key

When replacing hosts, we generally use new admin keys, but preserve the same public keys. This is because we cannot pause the world to switch hosts and at the same time change all websites and active web browsing sessions.

```
export TYPESENSE_BOOTSTRAP_KEY=...
export TYPESENSE_PUB_SEARCH_KEY=...

curl http://localhost:8108/keys \
  -X POST \
  -H "X-TYPESENSE-API-KEY: $TYPESENSE_BOOTSTRAP_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"value":"'$TYPESENSE_PUB_SEARCH_KEY'","description":"Search-only key.","actions": ["documents:search"], "collections": ["*"]}'
```

#### Create scrapers

Add these two secrets to the GitHub repo's settings:

* `TYPESENSE_HOST`: `typesense.jquery.com` (host-only, no port or protocol)
* `TYPESENSE_ADMIN_KEY`: (an admin key with rights to relevant collections)

Then add `/docsearch.config.json` and `/.github/workflows/typesense.yaml`  files
to the repository, similar to those in <https://github.com/qunitjs/qunitjs.com/>
or <https://github.com/jquery/api.jquery.com/>.

#### Setup a new server

Note that Typesense supports in-place upgrades that preserve and migrate the database automatically, so there is no need to set up a new server when updating Typesense itself. However, when performing routine Debiann upgrades, or if the server is lost for any reason, you can set up a new server as follows:

1. Check health: `https://search-XX.ops.jquery.net/health`
2. Setup admins
   * Run `sudo jq-typesense-create-admins` on the host
   * Save the new admin passwords to the jQuery Team vault
3. Add our current public key
   * Get the current public key used on our websites. You can find this in this in [jquery-wp-content](https://github.com/jquery/jquery-wp-content/blob/main/sites.php) or in the jQuery Team vault.
   * Run `sudo jq-typesense-add-pubkey "..."` to let this key query the new host.
4. Crawl all the sites.
   For each of these repositories:
   * change secret "TYPESENSE_HOST" to `search-XX.ops.jquery.net`
   * change secret "TYPESENSE_ADMIN_KEY"
   * run "typesense" workflow
   
   Repositories:
   * jquery.com: [repo settings](https://github.com/jquery/api.jquery.com/settings/secrets/actions), [workflow](https://github.com/jquery/api.jquery.com/actions/workflows/typesense.yaml)
   * jqueryui.com: [repo settings](https://github.com/jquery/jqueryui.com/settings/secrets/actions), [workflow](https://github.com/jquery/jqueryui.com/actions/workflows/typesense.yaml)
   * jquerymobile.com: [repo settings](https://github.com/jquery/jquerymobile.com/settings/secrets/actions), [workflow](https://github.com/jquery/jquerymobile.com/actions/workflows/typesense.yaml)
   * qunitjs.com: [repo settings](https://github.com/qunitjs/qunit/settings/secrets/actions), [workflow](https://github.com/qunitjs/qunit/actions/workflows/typesense.yaml)
   * amethyst: [repo settings](https://github.com/qunitjs/jekyll-theme-amethyst/settings/secrets/actions), [worflow](https://github.com/qunitjs/jekyll-theme-amethyst/actions/workflows/typesense.yaml)
5. Switch traffic of https://typesense.jquery.com/health by updating the origin of the "search" service in Fastly, to the new host.

## Former solutions

### Algolia DocSearch

The documentation sites used Algolia's DocSearch for autocompletion from 2013 to 2022. All use of Algolia was replaced with self-hosted Typesense in 2022.

Algolia was set up for jQuery in 2013 ([thread 1](https://github.com/jquery/api.jquery.com/issues/227),
[thread 2](https://github.com/jquery/api.jquery.com/issues/1104)) with the help
of Sylvain Pace who worked on Algolia DocSearch.

The sites are crawled passively by Algolia (interval unknown), via their
[algolia/docsearch-scraper](https://github.com/algolia/docsearch-scraper)
service. These configuration files were created for us and control the crawler:

* [/configs/jquery.json](https://github.com/algolia/docsearch-configs/blob/HEAD/configs/jquery.json)
* [/configs/jqueryui.json](https://github.com/algolia/docsearch-configs/blob/HEAD/configs/jqueryui.json)
* [/configs/jquerymobile.json](https://github.com/algolia/docsearch-configs/blob/HEAD/configs/jquerymobile.json)
* [/configs/qunitjs.json](https://github.com/algolia/docsearch-configs/blob/HEAD/configs/qunitjs.json)

The open source `algolia/docsearch-scraper` service was deprecated in 2021 in
favour of the propietary Algolia Crawler. The above configuration files
link to a now archived read-only repository. It is our understanding that
migration to the new Crawler is opt-in and requires client and configuration
changes. It appears the legacy crawler still runs although at unknown frequency
(seemingly less than once a month, if at all).

The algolia-docsearch.js client integration was part of the
<https://github.com/jquery/jquery-wp-content> repository.

### Algolia Free

From 2018 to 2022, QUnit used a standalone "Free" account, with active rather than passive crawling,
by pushing content directly to the Algolia API during website deployments. All use of Algolia was replaced with self-hosted Typesense in 2022.

* https://qunitjs.com/
* https://qunitjs.github.io/jekyll-theme-amethyst/

These used [jekyll-algolia]() during the CI job (GitHub Actions) to
build and deploy the static site. The frontend CSS and JS for the Algolia client
were part of the Amethyst theme for Jekyll:
<https://github.com/qunitjs/jekyll-theme-amethyst/>

See also its [Amethyst § Getting started](https://github.com/qunitjs/jekyll-theme-amethyst/blob/main/docs/getting-started.md).
