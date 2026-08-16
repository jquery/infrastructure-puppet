<?php
/**
 * Usage:
 *
 *     $ php test/FilestashTest.php
 *
 *     $ php test/WpblogsTest.php https://filestash-XX.ops.jquery.net
 */

require_once __DIR__ . '/Unit.php';
$server = rtrim( $argv[1] ?? 'https://releases.jquery.com/git', '/' );

Unit::start();

Unit::testHttp( $server . '/jquery-git.js', null, [], [
    'status' => '200',
    'content-type' => 'application/javascript; charset=utf-8',
  ], [
    'jQuery JavaScript Library'
  ]
);
Unit::testHttp( $server . '/ui/jquery-ui-git.js', null, [], [
    'status' => '200',
    'content-type' => 'application/javascript; charset=utf-8',
  ], [
    'jQuery UI'
  ]
);
Unit::testHttp( $server . '/ui/jquery-ui-git.css', null, [], [
    'status' => '200',
    'content-type' => 'text/css',
  ], [
    'jQuery UI'
  ]
);
Unit::testHttp( $server . '/mobile/git/jquery.mobile-git.js', null, [], [
    'status' => '200',
    'content-type' => 'application/javascript; charset=utf-8',
  ], [
    'jQuery Mobile'
  ]
);
Unit::testHttp( $server . '/mobile/git/images/icons-svg/back-black.svg', null, [], [
    'status' => '200',
    'content-type' => 'image/svg+xml',
  ], [
    '<?xml'
  ]
);
