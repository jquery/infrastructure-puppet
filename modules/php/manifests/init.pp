# @summary installs and manages php
class php (
  Array[Php::Extension] $extensions = [],
) {
  $version = debian::codename() ? {
    'bookworm' => '8.2',
    'trixie'   => '8.4',
    default    => fail('php: unsupported debian version'),
  }

  stdlib::ensure_packages([
    "php${version}-common",
    "php${version}-cli",
  ])

  stdlib::ensure_packages(
    $extensions.map |Php::Extension $ext| {
      if $ext =~ String[1] {
        "php${version}-${ext}"
      } elsif $ext['package'] {
        $ext['package']
      } else {
        fail('invalid package declaration')
      }
    }
  )
}
