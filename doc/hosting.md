# Hosting

Nodes managed by this Puppet repository are hosted at **DigitalOcean**.

* Management: <https://cloud.digitalocean.com/>
* Access
  * jQuery Infra Team members
  * LF IT via <https://support.linuxfoundation.org>

## Create new node

### Default

* Region: NYC3 (`nyc3-vpc-openjsf1`) or SFO3 (`default-sfo3`)
* Image: Debian (latest LTS).
* Plan: Typically a small dual-core plan unless more is needed, such as:
  * Shared CPU > Basic > Regular Intel > 2 CPUs 2GB RAM ($18/month in 2022)
  * Shared CPU > Basic > Regular Intel > 2 CPUs 4GB RAM ($24/month in 2022)
* Additional options: Monitoring.
* Authentication: SSH, add yourself and 1 team mate for initial bootstrapping. These will be replaced by Puppet later.
* Hostname: Refer to [dns.md](./dns.md).
