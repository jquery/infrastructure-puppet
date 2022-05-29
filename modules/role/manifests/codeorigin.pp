#
#
class role::codeorigin {
  include jquery::base

  package { 'nginx':
    ensure => present,
  }
}
