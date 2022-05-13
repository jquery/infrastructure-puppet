#
#
class role::gruntjscom {
  package { 'nodejs':
    ensure => present,
  }
}
