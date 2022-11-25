#
#
class role::gruntjscom {
  include profile::base

  package { 'nodejs':
    ensure => present,
  }
}
