# @summary Manages the Linux kernel installation
class kernel () {
  exec { 'update-initramfs':
    command     => '/usr/sbin/update-initramfs -u -k all',
    logoutput   => true,
    refreshonly => true,
  }
}
