# @summary a puppet server
class role::puppet () {
  include profile::base

  include profile::certbot
  include profile::notifier

  include profile::puppet::server
  include profile::puppet::puppetdb
}
