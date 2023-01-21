# @summary testswarm server
class role::testswarm {
  include profile::base
  include profile::testswarm::database
}
