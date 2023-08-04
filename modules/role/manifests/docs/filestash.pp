# @summary file stash for constantly updating release files
class role::docs::filestash {
  include profile::base

  include profile::certbot
  include profile::tarsnap

  include profile::filestash
}
