<?php
/**
 * Usage:
 *
 *     $ php test/WpblogsTest.php
 *
 *     $ php test/WpblogsTest.php wpblogs-XX.ops.jquery.net
 */

require_once __DIR__ . '/Unit.php';
$server = $argv[1] ?? null;

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

foreach ( [
  'https://blog.jquery.com/wp-content/uploads/2006/04/jQuery-Map.png',
  'https://blog.jqueryui.com/wp-content/uploads/2010/06/contextmenu.png',
  'https://blog.jqueryui.com/wp-content/uploads/2010/11/spinner-currency-demo.png',
  'https://blog.jquerymobile.com/wp-content/uploads/2012/01/jqm-transitions-loader.png',
  'https://blog.jquerymobile.com/wp-content/uploads/2012/02/flow2-264x300.png',
  'https://blog.jquerymobile.com/wp-content/uploads/2012/02/flow2.png',
] as $url ) {
  Unit::testHttp( $url, null, [], [
    'status' => '200',
    'content-type' => 'image/png',
  ] );
}
foreach ( [
  'https://blog.jquery.com/wp-content/uploads/2026/01/jquery-reunion-group-edited-1024x771.jpeg',
  'https://blog.jquery.com/wp-content/uploads/2026/01/jquery-reunion-group-edited.jpeg',
] as $url ) {
  Unit::testHttp( $url, null, [], [
    'status' => '200',
    'content-type' => 'image/jpeg',
  ] );
}


Unit::end();
