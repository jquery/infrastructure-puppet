#
#
class role::gruntjscom {
  include jquery::base

  package { 'nodejs':
    ensure => present,
  }
}
