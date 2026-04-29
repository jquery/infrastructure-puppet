# @summary Blocks the loading of a kernel module
define kernel::module::disallow (
  Jqlib::Ensure $ensure = 'present',
  String[1]     $module = $title,
) {
  file { "/etc/modprobe.d/disallow-${title}.conf":
    ensure  => stdlib::ensure($ensure, 'file'),
    content => template('kernel/module/disallow.erb'),
    notify  => Exec['update-initramfs'],
  }
}
