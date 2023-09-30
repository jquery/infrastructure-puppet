# @summary installs and manages php
class php (
  Array[Php::Extension] $extensions = [],
) {
  $version = debian::codename() ? {
    'bullseye' => '7.4',
    'bookworm' => '8.2',
    default    => fail('php: unsupported debian version'),
  }

  ensure_packages([
    "php${version}-common",
    "php${version}-cli",
  ])

  ensure_packages(
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
