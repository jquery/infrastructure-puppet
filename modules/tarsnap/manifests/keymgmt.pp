# @summary configures tarsnap key management support
class tarsnap::keymgmt (
  Stdlib::Unixpath $base_path,
  Stdlib::Email    $account_email,
  String[1]        $group,
) {
  file { '/usr/local/sbin/jq-tarsnap-keygen':
    ensure => file,
    source => 'puppet:///modules/tarsnap/keymgmt/jq-tarsnap-keygen.sh',
    mode   => '0500',
  }

  file { '/etc/jq-tarsnap-keygen.sh':
    ensure  => file,
    content => template('tarsnap/keymgmt/config.sh'),
    mode    => '0500',
  }

  file { $base_path:
    ensure => directory,
    mode   => '0750',
    owner  => 'root',
    group  => $group,
  }
}
