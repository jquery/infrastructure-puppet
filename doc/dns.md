# DNS

As of 2017, DNS for (most) OpenJS Foundation projects is managed via **Cloudflare**.

* Account type: [Enterprise](https://www.cloudflare.com/en-gb/plans/)
* Access:
  * jQuery Infra Team members
  * LF IT via <https://support.linuxfoundation.org>

## Naming conventions

### Internal hostname

Format: `<role-##>.ops.jquery.net` or `<role-##>.stage.ops.jquery.net`

Example: `wp-01.ops.jquery.net`, `wp-01.stage.ops.jquery.net`

These generally refer to the public IP address of a specific virtual machine (e.g. DigitalOcean droplet). We use public IPs to enable direct SSH access for debugging, and in some cases to allow access from a webhook. In the case of web services, we attach CNAME the `ops` hostname to the canonical public domain name (e.g. `something.jquery.com`), possibly via a CDN. 

### Internal service

Format: `<service>.jquery.net`

Example: `builder.jquery.net`, `builder.stage.jquery.net`

These are generally a CNAME to an internal hostname, and are meant to be used in non-user facing ways only. Typically for use cases that are considered project-internal in purpose, but managed outside our self-hosted infrastructure in ways that Puppet automation can't easily reach. This helps separate concerns and reduces risk of breakage due to untracked references.

For example, webhooks from the dozens of WordPress content repositories (like `jquery/api.jquery.com`) notify `builder.jquery.net` which then refers to currently primary builder.

### Public service

These are considered services for public use. Generally anything that we advertise to the general public, or to developers using/contributing to our software, or otherwise meant to be accessed in a web browser, falls under this. These should all support HTTPS (e.g. via Let's Encrypt certbot, or CDN proxy).

Examples of Tier-1 canonical domains of OpenJS projects that are hosted and/or monitored via jQuery Infrastructure.

| Tier-1 canonical domains | Example
|--|--
| `.jquery.com` | https://api.jquery.com
| `.jqueryui.com` | https://blog.jqueryui.com
| `.jquerymobile.com` | https://demos.jquerymobile.com
| `.qunitjs.com` | https://api.qunitjs.com
| `.jquery.org` | https://brand.jquery.org
| `.gruntjs.com` | https://gruntjs.com
| `.eslint.org` | https://eslint.org
| `.js.foundation` | https://js.foundation
| `.openjsf.org` | https://jenkins.openjsf.org
