# @summary docs sites wordpress host
class role::docs::wordpress {
  include profile::base

  include profile::certbot

  include profile::wordpress::docs
}
