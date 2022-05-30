#
#
class role::codeorigin {
  include jquery::base

  package { 'nginx':
    ensure => present,
  }

  realize(Jquery::Ssh_user['ori'])
}
