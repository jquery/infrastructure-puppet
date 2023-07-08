# TODO: It really feels like there should be a way to do this
# in Puppet DSL. There isn't (or at least I could not find that),
# so I wrote this in Ruby. Not sure if this could be generalized
# somehow.
Puppet::Functions.create_function(:'profile::miscweb::group_certificates') do
  dispatch :main do
    param 'Hash[Stdlib::Fqdn, Profile::Miscweb::Redirect]', :redirects
  end

  def main(redirects)
    redirects
      .filter { |_, site| site['certificate'] != nil }
      .group_by { |_, site| site['certificate'] }
      .transform_values { |cert| cert.map { |item| item[0] } }
  end
end

