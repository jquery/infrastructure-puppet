# Hosting

Nodes managed by this Puppet repository are hosted at **DigitalOcean**.

* Management: <https://cloud.digitalocean.com/>
* Access
  * jQuery Infra Team members
  * LF IT via <https://support.linuxfoundation.org>

## Create new node

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

Once created:
* Define the chosen hostname with the allocated IP in DNS
  * Cloudflare Dashboard > jquery.net zone > DNS
  * Create AAAA record
  * Proxy status: Off
* Follow [Puppet § Provisioning new nodes](./puppet.md).
