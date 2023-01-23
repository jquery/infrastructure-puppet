# @summary installs and manages php
class php () {
  $version = debian::codename() ? {
    'bullseye' => '7.4',
    default    => fail('php: unsupported debian version'),
  }

  ensure_packages([
    "php${version}",
  ])
}
