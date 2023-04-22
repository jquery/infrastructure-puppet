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

## Algolia DocSearch

Most of the documentation sites additionally use Algolia's DocSearch for
autocompletion. It was set up in 2013 ([thread 1](https://github.com/jquery/api.jquery.com/issues/227),
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

The algolia-docsearch.js client integration resides in the
<https://github.com/jquery/jquery-wp-content> repository.

## Algolia Free

A number of sites use an active rather than passive crawling, by
pushing content directly to the Algolia API during website deployments.

* https://qunitjs.com/
* https://api.qunitjs.com/
* https://qunitjs.github.io/jekyll-theme-amethyst/

These use [jekyll-algolia]() during the CI job (GitHub Actions) that
builds and deploys the static site. The frontend CSS and JS for this
are part of the Amethyst theme for Jekyll:
<https://github.com/qunitjs/jekyll-theme-amethyst/>

See also its [Getting started](https://github.com/qunitjs/jekyll-theme-amethyst/blob/main/docs/getting-started.md)
documentation for how to works in more detail.

## Typesense

As of 2021, we're exploring an open-source solution that we support
within our free software ecosystem, and that we can adopt without
a lower privacy budget by not sending PII to another third party.

### Background

In 2021, we first evaluated Meilisearch ([private thread](https://github.com/jquery/infrastructure/issues/522))
and experienced some suboptimal aspects that eventually made us
transition the experiment to Typesense. These reasons included:
difficult upgrades (not yet committing to forward compatibility or
automatic in-place upgrades), [opt-out telemetry](https://docs.meilisearch.com/learn/what_is_meilisearch/telemetry.html) instead of opt-in, no official Debian packages,
non-trivial interactive setup, missing support for querying multiple
indexes (e.g. qunitjs.com and api.qunitjs.com), and a not yet clear
future in terms of business model (Meilisearch Cloud was not
yet in the picture, and the backend is not GPL licensed).

### Runbook

* Canonical domain: https://typesense.jquery.com
* Bootstrap key: _(`profile::typesense::api_key` in [Private Hiera data](./puppet.md))_

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

#### Generate search-only key

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

#### Create scrapers

Add these two secrets to the GitHub repo's settings:

* `TYPESENSE_HOST`: `typesense.jquery.com` (host-only, no port or protocol)
* `TYPESENSE_ADMIN_KEY`: (an admin key with rights to relevant collections)

Then add `/docsearch.config.json` and `/.github/workflows/typesense.yaml`  files
to the repository, similar to those in <https://github.com/qunitjs/qunitjs.com/>
or <https://github.com/jquery/api.jquery.com/>.
