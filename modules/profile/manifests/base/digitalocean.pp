# @summary configures digitalocean specific settings
class profile::base::digitalocean () {
  # keyring is already provisioned on new instances
  apt::source { 'droplet-agent':
    location => 'https://repos-droplet.digitalocean.com/apt/droplet-agent',
    repos    => 'main',
    release  => 'main',
    keyring  => '/usr/share/keyrings/droplet-agent-keyring.gpg',
    pin      => 150,
  }

  ensure_packages([
    'droplet-agent',
    'droplet-agent-keyring'
  ], {
    require => Class['Apt::Update'],
  })
}
