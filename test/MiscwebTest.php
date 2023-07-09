<?php
/**
 * Usage: php test/MiscwebTest.php
 */

require_once __DIR__ . '/Unit.php';
$server = @$argv[1] ?: '';

Unit::start();

foreach ( [
  'http://dev.jqueryui.com/ticket/5462' => 'https://bugs.jqueryui.com/ticket/5462',
  'http://learn.jqueryui.com/something' => 'https://learn.jquery.com/jquery-ui/',
  'http://view.jquery.com/something' => 'https://releases.jquery.com/jquery/',
  'http://ui.jquery.com/about/' => 'https://jqueryui.com/about/',
  'http://ui.jquery.com/bugs/ticket/3484' => 'https://jqueryui.com/bugs/ticket/3484',
  'http://wiki.jqueryui.com/Droppable' => 'https://jqueryui.pbworks.com/Droppable',
] as $url => $expected ) {
  Unit::testHttp( $url, null, [], [
    'status' => '301',
    'location' => $expected,
  ] );
  $urlHttps = str_replace( 'http:', 'https:', $url );
  Unit::testHttp( $urlHttps, null, [], [
    'status' => '301',
    'location' => $expected,
  ] );
}

Unit::end();
