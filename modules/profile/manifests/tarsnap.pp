# @summary configures the tarsnap backup client
class profile::tarsnap () {
  class { 'tarsnap': }
}
