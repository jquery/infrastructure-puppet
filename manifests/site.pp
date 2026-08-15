# Docs:
# https://puppet.com/docs/puppet/7/lang_node_definitions.html
# https://puppet.com/docs/puppet/7/roles_and_profiles_example.html

# Please keep this file alphabetically sorted!

# Production
# ----------

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'builder-02.ops.jquery.net' {
  role('docs::builder')
}

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'codeorigin-04.ops.jquery.net' {
  role('codeorigin')
}

# 2 CPU, 2 GB mem, Debian 13 Trixie
node 'codeorigin-05.ops.jquery.net' {
  role('codeorigin')
}

# 2 CPU, 4 GB mem, Debian 13 Trixie, 80 GB disk (+Backups)
node 'contentorigin-03.ops.jquery.net' {
  role('contentorigin')
}

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'filestash-01.ops.jquery.net' {
  role('docs::filestash')
}

# 2 CPU, 2 GB mem, Debian 13 Trixie
node 'gruntjs-04.ops.jquery.net' {
  role('gruntjscom')
}

# 2 CPU, 2 GB mem, Debian 13 Trixie
node 'miscweb-03.ops.jquery.net' {
  role('miscweb')
}

# 2 CPU, 4 GB mem, Debian 12 Bookworm (+Backups)
node 'puppet-04.ops.jquery.net' {
  role('puppet')
}

# 2 CPU, 2 GB mem, Debian 12 Bookworm
node 'search-03.ops.jquery.net' {
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

# 4 CPU, 8 GB mem, Debian 13 Trixie (NYC3)
node 'wp-06.ops.jquery.net' {
  role('docs::wordpress')
}

# 4 CPU, 8 GB mem, Debian 13 Trixie (SFO3)
node 'wp-07.ops.jquery.net' {
  role('docs::wordpress')
}

# 2 CPU, 2 GB mem, Debian 13 Trixie (+Backups)
node 'wpblogs-03.ops.jquery.net' {
  role('blogs')
}

# Staging
# -------

# Debian 12 Bookworm
node 'builder-05.stage.ops.jquery.net' {
  role('docs::builder')
}

# 2 CPU, 2 GB mem, Debian 13 Trixie
node 'codeorigin-05.stage.ops.jquery.net' {
  role('codeorigin')
}

# 2 CPU, 4 GB mem, Debian 13 Trixie
node 'wp-04.stage.ops.jquery.net' {
  role('docs::wordpress')
}
