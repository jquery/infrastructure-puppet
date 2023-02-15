# @summary miscweb server
class role::miscweb {
  include profile::base
  include profile::certbot

  include profile::miscweb
}
