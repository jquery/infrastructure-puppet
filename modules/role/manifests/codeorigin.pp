#
#
class role::codeorigin {
  package { 'nginx':
    ensure => present,
  }
}
