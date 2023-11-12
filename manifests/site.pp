# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

# PLEASE KEEP THIS FILE ALPHABETICALLY SORTED

# Production
# ----------

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'builder-02.ops.jquery.net' {
  role('docs::builder')
}

# 2 CPU, 2 GB mem, Debian 11 Bullseye
node 'codeorigin-02.ops.jquery.net' {
  role('codeorigin')
}

# 2 CPU, 4 GB mem, Debian 11 Bullseye, 80 GB disk
node 'contentorigin-02.ops.jquery.net' {
  role('contentorigin')
}

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'filestash-01.ops.jquery.net' {
  role('docs::filestash')
}

# 1 CPU, 2 GB mem, Debian 11 Bullseye
node 'gruntjs-02.ops.jquery.net' {
  role('gruntjscom')
}

# 2 CPU, 2 GB mem, Debian 11 Bullseye
node 'miscweb-01.ops.jquery.net' {
  role('miscweb')
}

# 2 CPU, 4 GB mem, Debian 11 Bullseye
node 'puppet-03.ops.jquery.net' {
  role('puppet')
}

# 2 CPU, 4 GB mem, Debian 11 Bullseye, 80 GB disk
node 'swarm-02.ops.jquery.net' {
  role('testswarm')
}

# 2 CPU, 2 GB mem, Debian 11 Bullseye
node 'search-02.ops.jquery.net' {
  role('search')
}

# 4 CPU, 8 GB mem, Debian 12 Bookworm (NYC3)
node 'wp-04.ops.jquery.net' {
  role('docs::wordpress')
}

# 4 CPU, 8 GB mem, Debian 12 Bookworm (SFO3)
node 'wp-05.ops.jquery.net' {
  role('docs::wordpress')
}

# 1 CPU, 2 GB mem, Debian 11 Bullseye
node 'wpblogs-01.ops.jquery.net' {
  role('blogs')
}

# Staging
# -------

# Debian 11 Bullseye
node 'builder-04.stage.ops.jquery.net' {
  role('docs::builder')
}

# Debian 12 Bookworm
node 'builder-05.stage.ops.jquery.net' {
  role('docs::builder')
}

# Debian 11 Bullseye
node 'codeorigin-02.stage.ops.jquery.net' {
  role('codeorigin')
}

# Debian 11 Bullseye
node 'gruntjs-02.stage.ops.jquery.net' {
  role('gruntjscom')
}

# Debian 12 Bookworm
node 'wp-03.stage.ops.jquery.net' {
  role('docs::wordpress')
}
