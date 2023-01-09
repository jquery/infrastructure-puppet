# @summary configures tarsnap key management support
class tarsnap::keymgmt (
  Stdlib::Unixpath $base_path,
  Stdlib::Email    $account_email,
  String[1]        $user,
  String[1]        $group,
) {
  file { '/usr/local/sbin/jq-tarsnap-keygen':
    ensure => file,
    source => 'puppet:///modules/tarsnap/keymgmt/jq-tarsnap-keygen.sh',
    owner   => $user,
    group   => $group,
    mode   => '0550',
  }

  file { '/etc/jq-tarsnap-keygen.sh':
    ensure  => file,
    content => template('tarsnap/keymgmt/config.sh'),
    owner   => $user,
    group   => $group,
    mode    => '0550',
  }

  file { $base_path:
    ensure => directory,
    mode   => '2770',
    owner  => $user,
    group  => $group,
  }
}
