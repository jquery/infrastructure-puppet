<?php
/**
 * Usage: php test/ContentoriginTest.php
 */

require_once __DIR__ . '/Unit.php';

Unit::start();

foreach ( [
	'http://content.jquery.com',
	'http://content.origin.jquery.com',
	'https://content.jquery.com'
] as $server ) {
	Unit::testHttp( $server, '/podcast/wp-content/uploads/2010/09/jquerypodcast.png', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '61029',
		'content-type' => 'image/png',
	] );
	Unit::testHttp( $server, '/podcast/jQueryPodcast-001-JohnResig.mp3', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '36978091',
		'content-type' => 'audio/mpeg',
	] );
}

foreach ( [
	'http://static.jquery.com',
	'http://static.origin.jquery.com',
	'https://static.jquery.com'
] as $server ) {
	Unit::testHttp( $server, '/podcast/wp-content/uploads/2010/09/jquerypodcast.png', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '61029',
		'content-type' => 'image/png',
	] );
	Unit::testHttp( $server, '/files/rocker/images/logo_jquery_215x53.gif', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '4213',
		'content-type' => 'image/gif',
	] );
}

Unit::end();
