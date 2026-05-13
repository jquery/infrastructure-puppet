# Fastly

## See also

* [cdn.md](./cdn.md), our Fastly configuration in broad strokes.
* [cdn-cert.md](./cdn-cert.md), the annual renew process including how to upload it to Fastly.
* [runbook-fastly-debug.md](./runbook-fastly-debug.md), how to temporarily enable real-time logging.

## Fastly service domains

There appears to be no single place that documents all these together, so we've compiled this ourselves from public docs and emperical testing.

The format appears to be:

```
[dualstack].[letter].[kind].[region].fastly.net
```

References: [Working with CNAME](https://www.fastly.com/documentation/guides/getting-started/domains/working-with-domains/working-with-cname-records-and-your-dns-provider/), [2022 Archive](https://docs-archive.fastly.com/snapshots/static/2022-05-31-guides-aio.pdf), [2021 Archive](https://docs-archive.fastly.com/snapshots/static/2021-02-28-guides-aio.pdf), [Legacy Shared TLS](https://web.archive.org/web/20210730031032/https://docs.fastly.com/products/legacy-shared-tls-and-tls-wildcard-certificates-services), [Fastly blog: IPv6](https://www.fastly.com/blog/ipv6-fastly), [Fastly blog: HTTP/2](https://www.fastly.com/blog/http2-now-general-availability)).

* `[region]`:
  * `global`: Fastly's entire global network.
  * `us-eu`: North American and EU POPs only.
  * `<nothing>`: There appears to be a legacy map for some or all of the below variants that uses a presumed smaller subset or alternate set of POPs, under a different IP-range, and is IPv4-only and HTTP/1-only. 
* `[kind]`:
  * "sni": TLS 1.2+, HTTP/2+.
  * "ssl": TLS 1.2 only, HTTP/1 only.
  * "nonssl": Plaintext HTTP only.
  * ~~"shared"~~: "Shared SAN certicate" which included HTTP/2. Undocumented after 2022.
* `[letter]`: Specific TLS configurations for sni/ssl/shared kinds, detailed below.
   This component is absent for "nonssl".
   It appears that certifications are identified by letter+kind, such that letters in `sni` are distinct from those under `ssl` and `shared`. This means if you deploy a certificate to `k.sni`, you can freely choose between regions and dualstack, but you can't see it via "ssl" or "shared". 
* `[dualstack]`:  Optional prefix to enable IPv6.

### TLS-hostnames

Below uses `global` as the default region, but it is assumed (but not verified by us) that `us-eu` exists for all of these.

When "HTTP/2" is listed, this includes "HTTP/1" support.

When "HTTP/3" is listed, this includes "HTTP/1" and "HTTP/2" support.

For TLS versions, only the listed versions are supported.

| Identifier | Example hostname | TLS | HTTP | Comment
|--|--|--|--|--
| `j.sni` | `j.sni.global.fastly.net` | TLS 1.2, TLS 1.3 | HTTP/2 |[Enabling dualstack](https://www.fastly.com/documentation/guides/full-site-delivery/domains-and-origins/enabling-dualstack-connections/)
| `k.sni` | `k.sni.global.fastly.net` | TLS 1.2+CBC, TLS 1.3+0RTT | HTTP/2 | With legacy CBC ciphers for Windows 7 compat, [jquery/infrastructure-puppet#30](https://github.com/jquery/infrastructure-puppet/issues/30)
| `m.sni` | `m.sni.global.fastly.net` | TLS 1.2, TLS 1.3 | HTTP/3 | HTTP/3 experiment?, [2022 Archive](https://docs-archive.fastly.com/snapshots/static/2022-05-31-guides-aio.pdf)
| `n.sni` | `n.sni.global.fastly.net` | TLS 1.2, TLS 1.3+0RTT | HTTP/3 | HTTP/3 experiment?, [2022 Archive](https://docs-archive.fastly.com/snapshots/static/2022-05-31-guides-aio.pdf)
| `o.sni` | `o.sni.global.fastly.net` | TLS 1.0-1.2+CBC, TLS 1.3 | HTTP/2 | ..
| `r.sni` | `r.sni.global.fastly.net` | TLS 1.0-1.2+CBC, TLS 1.3+0RTT | HTTP/2 | With legacy CBC ciphers for Windows 7 compat, as well as legacy TLS 1.0 and TLS 1.1, [jquery/infrastructure-puppet#85](https://github.com/jquery/infrastructure-puppet/issues/85#issuecomment-4550525489)
| `s.sni` | `s.sni.global.fastly.net` | TLS 1.2, TLS 1.3 | HTTP/3 | ..
| `t.sni` | `t.sni.global.fastly.net` | TLS 1.2, TLS 1.3+0RTT | HTTP/3 | [Your own certificates](https://www.fastly.com/documentation/guides/getting-started/domains/securing-domains/setting-up-tls-with-your-own-certificates/)

The `ssl` kind letters seem to be interchangable with `shared`, so only one is shown:

| Identifier | Example hostname | TLS | HTTP | Comment
|--|--|--|--|--
| `g.ssl` | `g.ssl.global.fastly.net` | .. | .. | Shared SAN? [Fastly blog: HTTP/2](https://www.fastly.com/blog/http2-now-general-availability)
| `k.ssl` | `k.ssl.global.fastly.net` | .. | .. | Shared SAN? [Fastly blog: HTTP/2](https://www.fastly.com/blog/http2-now-general-availability)
| `m.ssl` | `m.ssl.global.fastly.net` | TLS 1.2 only | HTTP/1 only | Shared SAN? [2022 Archive](https://docs-archive.fastly.com/snapshots/static/2022-05-31-guides-aio.pdf), [TLS quick start](https://www.fastly.com/documentation/guides/getting-started/domains/securing-domains/tls-quick-start/)

Unless otherwise indicated, these are IPv4-only. There is a `dualstack.*` variant of all these which adds IPv6 support ([Fastly blog: IPv6](https://www.fastly.com/blog/ipv6-fastly)), [TLS quick start](https://www.fastly.com/documentation/guides/getting-started/domains/securing-domains/tls-quick-start/), [Enabling dualstack](https://www.fastly.com/documentation/guides/full-site-delivery/domains-and-origins/enabling-dualstack-connections/), [Working with CNAME](https://www.fastly.com/documentation/guides/getting-started/domains/working-with-domains/working-with-cname-records-and-your-dns-provider/)).

For example:

* `dualstack.g.shared.global.fastly.net`
* `dualstack.g.shared.us-eu.fastly.net`
* `dualstack.g.ssl.global.fastly.net`
* `dualstack.g.ssl.us-eu.fastly.net`
* `dualstack.k.sni.global.fastly.net`
* `dualstack.m.sni.global.fastly.net`
* `dualstack.n.sni.global.fastly.net`
* `dualstack.r.sni.global.fastly.net`
* `dualstack.t.sni.global.fastly.net`
* ...

### Non-TLS hostnames

* `nonssl.global.fastly.net`
* `nonssl.us-eu.fastly.net`
* `dualstack.nonssl.global.fastly.net`
* `dualstack.nonssl.us-eu.fastly.net`