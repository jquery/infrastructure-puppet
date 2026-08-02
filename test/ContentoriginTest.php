<?php
/**
 * Usage: php test/ContentoriginTest.php
 */
/**
 * Usage: php test/ContentoriginTest.php contentorigin-XX.ops.jquery.net
 */
require_once __DIR__ . '/Unit.php';
$server = $argv[1] ?? null;

Unit::start();

foreach ( $server ? [ "https://$server" ] : [
	'http://content.jquery.com',
	'https://content.jquery.com',
	'http://content.origin.jquery.com',
	'http://static.jquery.com',
	'https://static.jquery.com',
	'http://static.origin.jquery.com',
] as $origin ) {
	Unit::testHttp( $origin, '/podcast/wp-content/uploads/2010/09/jquerypodcast.png', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '61029',
		'content-type' => 'image/png',
	] );
	Unit::testHttp( $origin, '/podcast/jQueryPodcast-001-JohnResig.mp3', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '36978091',
		'content-type' => 'audio/mpeg',
	] );
	Unit::testHttp( $origin, '/podcast/wp-content/uploads/2010/09/jquerypodcast.png', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '61029',
		'content-type' => 'image/png',
	] );
	Unit::testHttp( $origin, '/files/rocker/images/logo_jquery_215x53.gif', [], [
		'status' => '200',
		'accept-ranges' => 'bytes',
		'access-control-allow-origin' => '*',
		'cache-control' => 'max-age=2592000',
		'content-length' => '4213',
		'content-type' => 'image/gif',
	] );
}

Unit::end();
