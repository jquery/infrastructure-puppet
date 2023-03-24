# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

# Production

node 'codeorigin-02.ops.jquery.net' {
  role('codeorigin')
}

node 'contentorigin-02.ops.jquery.net' {
  role('contentorigin')
}

node 'gruntjs-02.ops.jquery.net' {
  role('gruntjscom')
}

node 'puppet-03.ops.jquery.net' {
  role('puppet')
}

node 'swarm-02.ops.jquery.net' {
  role('testswarm')
}

node 'miscweb-01.ops.jquery.net' {
  role('miscweb')
}

node 'wpblogs-01.ops.jquery.net' {
  role('blogs')
}

# Staging

node 'codeorigin-02.stage.ops.jquery.net' {
  role('codeorigin')
}

node 'gruntjs-02.stage.ops.jquery.net' {
  role('gruntjscom')
}
