# @summary code origin server
class profile::codeorigin () {
  nginx::site { 'codeorigin':
    content => template('profile/codeorigin/site.nginx.erb'),
  }
}
