# @summary installs certbot
# @param $email email to use for notifications
class profile::certbot (
  Stdlib::Email $email = lookup('profile::certbot::email'),
) {
  class { 'letsencrypt::certbot':
    email => $email,
  }
}
