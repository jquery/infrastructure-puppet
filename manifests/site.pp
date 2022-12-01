# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

# Production

node 'codeorigin-02.ops.jquery.net' {
  role('codeorigin')
}

node 'puppet-03.ops.jquery.net' {
  role('puppet')
}

# Staging

node 'codeorigin-02.stage.ops.jquery.net' {
  role('codeorigin')
}

node 'puppet-03.stage.ops.jquery.net' {
  role('puppet')
}
