# @summary ssh client configuration
class ssh::client (
  Boolean $enable_ssh_ca,
) {
  if $enable_ssh_ca {
    $ca_pub_data = jqlib::secret('ssh_ca/ca.pub')
    file { '/etc/ssh/ssh_known_hosts':
      ensure  => file,
      content => "@cert-authority *.ops.jquery.net ${ca_pub_data}\n",
      mode    => '0444',
    }
  }
}
