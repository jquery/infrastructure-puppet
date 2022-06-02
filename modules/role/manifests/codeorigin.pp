#
#
class role::codeorigin {
  include jquery::base
  include nginx

  nginx::site { 'codeorigin':
    source  => 'puppet:///modules/role/codeorigin.nginx',
    notify  => Exec['nginx-reload'],
  }
}
