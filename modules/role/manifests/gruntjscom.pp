# @summary gruntjs.com server
class role::gruntjscom {
  include profile::base
  include profile::certbot
  include profile::notifier
  include profile::gruntjscom
}
