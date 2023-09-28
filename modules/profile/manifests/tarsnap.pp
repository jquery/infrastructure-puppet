# @summary configures the tarsnap backup client
class profile::tarsnap (
  Boolean $enable = lookup('profile::tarsnap::enabled', {default_value => true}),
) {
  if $enable {
    class { 'tarsnap': }
  }
}
