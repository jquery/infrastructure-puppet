# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

# PLEASE KEEP THIS FILE ALPHABETICALLY SORTED

# Production
# ----------

# 2 CPU, 2 GB mem
node 'codeorigin-02.ops.jquery.net' {
  role('codeorigin')
}

# 2 CPU, 4 GB mem, 80 GB disk
node 'contentorigin-02.ops.jquery.net' {
  role('contentorigin')
}

# 2 CPU, 2 GB mem
node 'filestash-01.ops.jquery.net' {
  role('docs::filestash')
}

# 1 CPU, 2 GB mem
node 'gruntjs-02.ops.jquery.net' {
  role('gruntjscom')
}

# 2 CPU, 2 GB mem
node 'miscweb-01.ops.jquery.net' {
  role('miscweb')
}

# 2 CPU, 4 GB mem
node 'puppet-03.ops.jquery.net' {
  role('puppet')
}

# 2 CPU, 4 GB mem, 80 GB disk
node 'swarm-02.ops.jquery.net' {
  role('testswarm')
}

# 2 CPU, 2 GB mem
node 'search-02.ops.jquery.net' {
  role('search')
}

# 4 CPU, 8 GB mem (NYC3)
node 'wp-04.ops.jquery.net' {
  role('docs::wordpress')
}

# 4 CPU, 8 GB mem (SFO3)
node 'wp-05.ops.jquery.net' {
  role('docs::wordpress')
}

# 1 CPU, 2 GB mem
node 'wpblogs-01.ops.jquery.net' {
  role('blogs')
}

# Staging
# -------

node 'builder-04.stage.ops.jquery.net' {
  role('docs::builder')
}

node 'codeorigin-02.stage.ops.jquery.net' {
  role('codeorigin')
}

node 'gruntjs-02.stage.ops.jquery.net' {
  role('gruntjscom')
}

node 'wp-02.stage.ops.jquery.net' {
  role('docs::wordpress')
}
