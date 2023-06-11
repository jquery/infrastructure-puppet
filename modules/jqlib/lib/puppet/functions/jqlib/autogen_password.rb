# https://gerrit.wikimedia.org/r/plugins/gitiles/operations/puppet/+/refs/heads/production/modules/wmflib/lib/puppet/functions/wmflib/autogen_password.rb
# (c) Wikimedia Foundation, licensed under the Apache 2.0 license.

require 'digest/sha2'

Puppet::Functions.create_function(:'jqlib::autogen_password') do
  # returns a 20-character-limited string to be used as a password
  # @param username the username to generate the password for
  # @param seed the seed to use to generate the password.
  dispatch :autogen_password do
    param 'String', :username
    param 'String', :seed
  end

  def autogen_password(username, seed)
    Digest::SHA256.hexdigest("#{seed}|||#{username}")[0..20]
  end
end
