<?php
/**
 * Usage: php test/WpdocsTest.php
 */

require_once __DIR__ . '/Unit.php';

Unit::start();

foreach ( [
  'https://jquery.com/api' => 'https://api.jquery.com',
  'https://jquery.com/api/' => 'https://api.jquery.com',
  'https://jquery.com/blog/feed' => 'https://blog.jquery.com/feed',
  'https://jquery.com/blog/feed/' => 'https://blog.jquery.com/feed/',
  'https://jquery.com/dev/bugs/new/' => 'https://bugs.jquery.com',
  'https://jquery.com/dev/svn/trunk/plugins/' => 'https://bugs.jquery.com',
  'https://jquery.com/docs/Base/Expression/' => 'https://api.jquery.com',
  'https://jquery.com/latest' => 'https://code.jquery.com',
  'https://jquery.com/blog/2008/09/28/jquery-microsoft-nokia' => 'https://blog.jquery.com/2008/09/28/jquery-microsoft-nokia',

  'https://jqueryui.com/latest/ui/jquery.effects.core.js' => 'https://code.jquery.com',
  'https://jqueryui.com/docs/Changelog/1.13.0' => 'https://jqueryui.com/changelog/1.13.0',
  'https://jqueryui.com/docs/Theming' => 'https://learn.jquery.com/jquery-ui/theming/',
  'https://jqueryui.com/docs/About' => 'https://jqueryui.com/About',
  'https://jqueryui.com/docs/dialog' => 'https://jqueryui.com/dialog',
  'https://jqueryui.com/bugs/ticket/3484' => 'https://bugs.jqueryui.com/ticket/3484',

  'https://jquerymobile.com/blog/feed' => 'https://blog.jquerymobile.com/feed',
  'https://jquerymobile.com/blog/feed/' => 'https://blog.jquerymobile.com/feed/',
  'https://jquerymobile.com/blog/2011/11/16/announcing-jquery-mobile-1-0/' => 'https://blog.jquerymobile.com/2011/11/16/announcing-jquery-mobile-1-0/',

  'https://jquery.org/feed/' => 'https://meetings.jquery.org/feed/',

  'https://contribute.jquery.org/CLA/status/' => 'https://cla.openjsf.org',

  'https://releases.jquery.com/jquery' => 'https://releases.jquery.com/jquery/',
  'https://releases.jquery.com/ui' => 'https://releases.jquery.com/ui/',
  'https://releases.jquery.com/qunit' => 'https://releases.jquery.com/qunit/',
  'https://releases.jquery.com/mobile' => 'https://releases.jquery.com/mobile/',
  'https://releases.jquery.com/color' => 'https://releases.jquery.com/color/',

] as $url => $expected ) {
  Unit::testHttp( $url, null, [], [
    'status' => '301',
    'location' => $expected,
  ] );
}

foreach ( [
  'https://jquery.com/discuss/' => 'https://forum.jquery.com/',
  'https://jquery.com/discuss/2006-May/000804/' => 'https://www.mail-archive.com/discuss@jquery.com/',
  'https://jquery.com/forum' => 'https://forum.jquery.com',
  'https://jquery.com/plugins' => 'https://plugins.jquery.com',
  'https://jquery.com/src' => 'https://code.jquery.com',
  'https://jquery.com/ui' => 'https://jqueryui.com',
  'https://jquery.com/view' => 'https://view.jquery.com',

  'https://api.jquery.com/api' => 'https://api.jquery.com/resources/api.xml',
  'https://api.jquery.com/api/foo' => 'https://api.jquery.com/resources/api.xml',

  'https://api.jqueryui.com/api' => 'https://api.jqueryui.com/resources/api.xml',
  'https://api.jqueryui.com/api/foo' => 'https://api.jqueryui.com/resources/api.xml',

  'https://api.jquerymobile.com/api' => 'https://api.jquerymobile.com/resources/api.xml',
  'https://api.jquerymobile.com/api/foo' => 'https://api.jquerymobile.com/resources/api.xml',

] as $url => $expected ) {
  Unit::testHttp( $url, null, [], [
    'status' => '302',
    'location' => $expected,
  ] );
}

Unit::end();
