#
#
class jquery::base {
  group { 'wheel':
    ensure => present,
  }

  # https://voxpupuli.org/blog/2014/08/24/purging-ssh-authorized-keys/
  # https://github.com/jquery/infrastructure/issues/531
  user { 'root':
    ensure => present,
    home => '/root',
    uid => '0',
    purge_ssh_keys => true,
  }

  # Declare user accounts

  @jquery::ssh_user { 'krinkle':
    ensure   => present,
    root     => true,
    # last changed in 2021
    key_type => 'ssh-ed25519',
    key      => 'AAAAC3NzaC1lZDI1NTE5AAAAIKlog28hp/12C14a64e/we2bHpjRCqgCA3//Li1HmaI6',
    password => '$6$1MALPACAS$PTS/IyRB05E.iDHrNKed1MDECLUPh9LLepSDmfET3d0w3/no45xf5A/118AU6qltRIlgb4QPHLWPj5hUOdlyx0',
  }

  # Global roots are realized here.
  # Local rools can be realized in individual roles.
  realize(Jquery::Ssh_user['krinkle'])
}
