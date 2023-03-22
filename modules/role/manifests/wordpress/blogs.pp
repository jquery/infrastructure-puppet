# @summary blogs
class role::wordpress::blogs {
  include profile::base

  include profile::certbot
  include profile::tarsnap

  include profile::wordpress::blogs
}
