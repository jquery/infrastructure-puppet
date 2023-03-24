# @summary blog sites
class role::blogs {
  include profile::base

  include profile::certbot
  include profile::tarsnap

  include profile::wordpress::blogs
}
