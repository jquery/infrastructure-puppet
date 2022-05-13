# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

node 'codeorigin-01.stage.ops.jquery.net' {
    include role::codeorigin
}
