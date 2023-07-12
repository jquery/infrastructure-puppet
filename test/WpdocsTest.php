<?php
/**
 * Usage: php test/WpdocsTest.php
 */

require_once __DIR__ . '/Unit.php';
$server = @$argv[1] ?: '';

Unit::start();

foreach ( [
  'https://jqueryui.com/bugs/ticket/3484' => 'http://bugs.jqueryui.com/ticket/3484',
] as $url => $expected ) {
  Unit::testHttp( $url, null, [], [
    'status' => '301',
    'location' => $expected,
  ] );
}

foreach ( [
  'https://jquery.com/blog/feed/' => 'https://blog.jquery.com/feed/',
  'https://jquery.com/blog/2008/09/28/jquery-microsoft-nokia' => 'https://blog.jquery.com/2008/09/28/jquery-microsoft-nokia',
] as $url => $expected ) {
  Unit::testHttp( $url, null, [], [
    'status' => '302',
    'location' => $expected,
  ] );
}

Unit::end();
