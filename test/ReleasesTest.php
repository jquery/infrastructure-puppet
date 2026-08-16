<?php
/**
 * Usage: php test/ReleasesTest.php
 */

require_once __DIR__ . '/Unit.php';

Unit::start();

Unit::testHttp( 'https://releases.jquery.com/git/jquery-git.js', null, [], [
	'status' => '200',
	'content-type' => 'application/javascript; charset=utf-8',
	'vary' => 'Accept-Encoding',
	'cache-control' => 'max-age=300, public',
	'access-control-allow-origin' => '*',
] );

Unit::end();
