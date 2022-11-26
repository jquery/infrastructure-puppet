# @summary code origin server
class role::codeorigin {
  include profile::base
  include profile::certbot
  include profile::codeorigin
}
