# @summary manages the user accounts on this system
class users {
  # https://voxpupuli.org/blog/2014/08/24/purging-ssh-authorized-keys/
  # https://github.com/jquery/infrastructure/issues/531
  user { 'root':
    ensure         => present,
    home           => '/root',
    uid            => '0',
    purge_ssh_keys => true,
  }

  # Passwordless sudo for members of 'sudo' group.
  file { '/etc/sudoers.d/10-passwordless_sudo':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => "%sudo	ALL=(ALL) NOPASSWD: ALL\n",
  }

  # Declare user accounts

  @users::account { 'krinkle':
    ensure   => present,
    root     => true,
    # last changed in 2021
    key_type => 'ssh-ed25519',
    key      => 'AAAAC3NzaC1lZDI1NTE5AAAAIKlog28hp/12C14a64e/we2bHpjRCqgCA3//Li1HmaI6',
    uid      => 1200,
  }

  @users::account { 'ori':
    ensure   => present,
    root     => true,
    # last changed in 2021
    key_type => 'ssh-rsa',
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDWmB7Tn7zcL5Q7FniKka8MlJN4SfCpCtCXvBd0BpXVEPh+AGlmvulArUJ1/i1Z9TVO3PoS7N+wahdxwsFv/Vx1K/xhEZ85jNvYDWaEokTAGuyE5I4R/+8XzX0Iy5s1cmLDwXNEYT7ManNN7YeWIl+D9XtPgyOhhEifX0JFb/ZxyX2Iy+Vfq5v7eA00wA8PXs5nxsZUZXOwusrALVfYPt9UyJzqyK7x82Dw+ZPkIfc9V2/gWk3xVOrdt0TvcjfTypP8CJ6qzD+fNQwmne+tRwQUVMu60s8Ra2b7e10bjw1bxpDqWltE7V5FaeKsQelfO4PgdE0otTVsfFXKX46zGzTWVI7XMX41loLCf5QpVesnW+sQDD9qdcuCeUZDirQ/WjjLRPM5o92dV3OFFff+tXaVGk1dKoQcLecXy/se+ViZnydXT0o4DytF4nLn1biiYcVSSASx3htJe70+sdALQ1cVEh8kB3UGeWB2MhAlzLULC0+nRha3Z3r+P1RUEBR3yzx4GTuGid6txQeeeXp7u3SJYonJutpw9CfZheEtU8CLJm4aj3/kxccsWf3Sr6jsp+1f0TSeMMYZCI9OUVwSF2WrFzJnScPTFjP7i3z922ajIB2ADvGUKsPiRhGinqLEWMhShOJTQehCQ4k+Q6ab38aBtph7O+BYMA/aJl4X6WaLCQ==',
    uid      => 1201,
  }

  @users::account { 'taavi':
    ensure   => present,
    root     => true,
    key_type => 'ssh-ed25519',
    key      => 'AAAAC3NzaC1lZDI1NTE5AAAAIEbXQ4PFT2Or3t8Y1M0pvN4/9KAU39QupA/xu1/+x6n1',
    uid      => 1202,
  }

  # Global roots are realized here.
  # Local rools can be realized somewhere else.
  # TODO: don't use virtual resources here
  realize(Users::Account['krinkle'])
  realize(Users::Account['ori'])
  realize(Users::Account['taavi'])
}
