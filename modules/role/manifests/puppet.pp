# @summary a puppet server
class role::puppet () {
  include profile::base
  include profile::puppet::server
}
