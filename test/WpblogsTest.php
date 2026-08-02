<?php
/**
 * Usage:
 *
 *     $ php test/WpblogsTest.php
 *
 *     $ php test/WpblogsTest.php wpblogs-XX.ops.jquery.net
 */

require_once __DIR__ . '/Unit.php';
$server = $argv[1] ?? 'wpblogs-01.ops.jquery.net';

Unit::start();

Unit::testHttp( $server, 'https://blog.jquery.com/2008/09/28/jquery-microsoft-nokia/', [], [
    'status' => '200',
  ], [
    'We have two pieces of fantastic'
  ]
);
Unit::testHttp( $server, 'https://blog.jqueryui.com/2013/01/jquery-ui-1-10-0/', [], [
    'status' => '200',
  ], [
    'the first stable release of jQuery UI 1.10'
  ]
);
Unit::testHttp( $server, 'https://blog.jquerymobile.com/2011/11/16/announcing-jquery-mobile-1-0/', [], [
    'status' => '200',
  ], [
    'When we first launched this site'
  ]
);

Unit::end();
