# @summary generates reasonably secure TLS version and cipher suite
# configuration for infrastructure sites and backend communication
function nginx::tls_config () >> Array[String] {
  # https://nginx.org/en/docs/http/configuring_https_servers.html
  # https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices#2-configuration

  # no 1.0 or 1.1
  $protocols = ['TLSv1.2', 'TLSv1.3']

  # qualys
  $ciphers = [
    'ECDHE-ECDSA-AES128-GCM-SHA256',
    'ECDHE-ECDSA-AES256-GCM-SHA384',
    'ECDHE-ECDSA-AES128-SHA',
    'ECDHE-ECDSA-AES256-SHA',
    'ECDHE-ECDSA-AES128-SHA256',
    'ECDHE-ECDSA-AES256-SHA384',
    'ECDHE-RSA-AES128-GCM-SHA256',
    'ECDHE-RSA-AES256-GCM-SHA384',
    'ECDHE-RSA-AES128-SHA',
    'ECDHE-RSA-AES256-SHA',
    'ECDHE-RSA-AES128-SHA256',
    'ECDHE-RSA-AES256-SHA384',
    'DHE-RSA-AES128-GCM-SHA256',
    'DHE-RSA-AES256-GCM-SHA384',
    'DHE-RSA-AES128-SHA',
    'DHE-RSA-AES256-SHA',
    'DHE-RSA-AES128-SHA256',
    'DHE-RSA-AES256-SHA256',
  ]

  $ret = [
    "ssl_protocols ${protocols.join(' ')};",
    "ssl_ciphers ${ciphers.join(':')};",
    'ssl_prefer_server_ciphers on;',
  ]
  $ret
}
