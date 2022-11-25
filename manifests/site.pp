# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

node 'codeorigin-02.stage.ops.jquery.net' {
  include role::codeorigin
}

node 'puppet-03.stage.ops.jquery.net' {
  include role::puppet
}
