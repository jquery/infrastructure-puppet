# @summary installs and manages php
class php (
  Array[String[1]] $extensions = [],
) {
  $version = debian::codename() ? {
    'bullseye' => '7.4',
    default    => fail('php: unsupported debian version'),
  }

  ensure_packages([
    "php${version}",
  ])

  ensure_packages(
    $extensions.map |String[1] $ext| { "php${version}-${ext}" }
  )
}
