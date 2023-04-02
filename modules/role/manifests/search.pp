# @summary Search suggestion service for docs sites
class role::search {
  include profile::base
  include profile::certbot
  include profile::typesense
}
