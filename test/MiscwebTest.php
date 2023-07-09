<?php
/**
 * Usage: php test/MiscwebTest.php
 */

require_once __DIR__ . '/Unit.php';
$server = @$argv[1] ?: '';

Unit::start();

foreach ( [
  [ 'dev.jqueryui.com', '/ticket/5462', 'https://bugs.jqueryui.com/ticket/5462' ],
  [ 'learn.jqueryui.com', '/something', 'https://learn.jquery.com/jquery-ui/' ],
  [ 'view.jquery.com', '/something', 'https://releases.jquery.com/jquery/' ],
  [ 'ui.jquery.com', '/about/', 'https://jqueryui.com/about/' ],
] as [ $host, $path, $expected ] ) {
  Unit::testHttp( "http://$host", $path, [], [
    'status' => '301',
    'location' => $expected,
  ] );
  Unit::testHttp( "https://$host", $path, [], [
    'status' => '301',
    'location' => $expected,
  ] );
}

Unit::end();
