# @summary testswarm server
class role::testswarm {
  include profile::base
  include profile::certbot
  include profile::notifier

  include profile::testswarm::database
  include profile::testswarm::server
}
