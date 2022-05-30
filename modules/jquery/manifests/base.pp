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

  @jquery::ssh_user { 'ori':
    ensure   => present,
    root     => true,
    # last changed in 2021
    key_type => 'ssh-rsa',
    key      => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDWmB7Tn7zcL5Q7FniKka8MlJN4SfCpCtCXvBd0BpXVEPh+AGlmvulArUJ1/i1Z9TVO3PoS7N+wahdxwsFv/Vx1K/xhEZ85jNvYDWaEokTAGuyE5I4R/+8XzX0Iy5s1cmLDwXNEYT7ManNN7YeWIl+D9XtPgyOhhEifX0JFb/ZxyX2Iy+Vfq5v7eA00wA8PXs5nxsZUZXOwusrALVfYPt9UyJzqyK7x82Dw+ZPkIfc9V2/gWk3xVOrdt0TvcjfTypP8CJ6qzD+fNQwmne+tRwQUVMu60s8Ra2b7e10bjw1bxpDqWltE7V5FaeKsQelfO4PgdE0otTVsfFXKX46zGzTWVI7XMX41loLCf5QpVesnW+sQDD9qdcuCeUZDirQ/WjjLRPM5o92dV3OFFff+tXaVGk1dKoQcLecXy/se+ViZnydXT0o4DytF4nLn1biiYcVSSASx3htJe70+sdALQ1cVEh8kB3UGeWB2MhAlzLULC0+nRha3Z3r+P1RUEBR3yzx4GTuGid6txQeeeXp7u3SJYonJutpw9CfZheEtU8CLJm4aj3/kxccsWf3Sr6jsp+1f0TSeMMYZCI9OUVwSF2WrFzJnScPTFjP7i3z922ajIB2ADvGUKsPiRhGinqLEWMhShOJTQehCQ4k+Q6ab38aBtph7O+BYMA/aJl4X6WaLCQ==',
    password => '$6$djepS7kPEyeAiNjR$NtdU0oWECnwjKdIaUN1LzXe5DFd9BLrGwUmx00867AeAyYrAB4iC7hOnfkhKOsOF3PCRHfRTOQSIBWY3E26WU0',
  }

  # Global roots are realized here.
  # Local rools can be realized in individual roles.
  realize(Jquery::Ssh_user['krinkle'])
}
