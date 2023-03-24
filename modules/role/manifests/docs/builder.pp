# @summary docs sites builder
class role::docs::builder {
  include profile::base

  include profile::certbot
  include profile::notifier

  include profile::builder
}
