#
#
class role::codeorigin {
  include profile::base
  include nginx

  nginx::site { 'codeorigin':
    source => 'puppet:///modules/role/codeorigin.nginx',
    notify => Exec['nginx-reload'],
  }
}
