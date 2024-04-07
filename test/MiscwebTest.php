<?php
/**
 * Usage: php test/MiscwebTest.php
 */

require_once __DIR__ . '/Unit.php';
$server = @$argv[1] ?: '';

Unit::start();

foreach ( [
  'https://dev.jquery.com/ticket/7144' => 'https://bugs.jquery.com/ticket/7144',
  'http://dev.jqueryui.com/ticket/5462' => 'https://bugs.jqueryui.com/ticket/5462',
  'http://learn.jqueryui.com/something' => 'https://learn.jquery.com/jquery-ui/',
  'http://view.jquery.com/something' => 'https://releases.jquery.com/jquery/',
  'http://ui.jquery.com/about/' => 'https://jqueryui.com/about/',
  'http://ui.jquery.com/docs/dialog' => 'https://jqueryui.com/docs/dialog',
  'http://ui.jquery.com/bugs/ticket/3484' => 'https://jqueryui.com/bugs/ticket/3484',
  'http://ui.jquery.com/latest/ui/jquery.effects.core.js' => 'https://jqueryui.com/latest/ui/jquery.effects.core.js',
  'http://wiki.jqueryui.com/Droppable' => 'https://jqueryui.pbworks.com/Droppable',
  'http://docs.jquery.com/Core/each' => 'https://api.jquery.com/each/',
  'http://docs.jquery.com/UI/API/1.7.1/Datepicker' => 'https://api.jqueryui.com/datepicker/',
  'http://docs.jquery.com/QUnit/deepEqual' => 'https://api.qunitjs.com/deepEqual/',
  'http://docs.jquery.com/$' => 'https://api.jquery.com/jQuery/',
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
