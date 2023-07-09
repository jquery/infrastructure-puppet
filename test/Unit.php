<?php

// Support: PHP 7.4
if ( !function_exists( 'str_starts_with' ) ) {
	function str_starts_with( $haystack, $needle ) {
		return strpos( $haystack, $needle ) === 0;
	}
}

function jq_req( $url, array $reqHeaders = [] ) {
  Unit::verbose( "# $url\n" );
	$ch = curl_init( $url );
	$resp = [ 'headers' => [], 'body' => null ];
	curl_setopt_array( $ch, [
		CURLOPT_HTTPHEADER => $reqHeaders,
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_FOLLOWLOCATION => 0,
		CURLOPT_HEADERFUNCTION => function( $ch, $header ) use ( &$resp ) {
			$caseInsensitiveHeaders = [
				'connection'
			];
			$len = strlen( $header );
			// Both HTTP/1.1 and HTTP/2 are valid
			// Under HTTP/2, the status code is an integer without textual reason
			if ( preg_match( "/^(HTTP\/(?:1\.[01]|2)) (\d+)/", $header, $m ) ) {
				$resp['headers'] = [];
				$resp['headers']['status'] = trim( $m[2] );
			} else {
				$parts = explode( ':', $header, 2 );
				if ( count( $parts ) === 2 ) {
					$name = strtolower( $parts[0] );
					$val = trim( $parts[1] );
					if ( in_array( $name, $caseInsensitiveHeaders ) ) {
						$val = strtolower( $val );
					}
					if ( isset( $resp['headers'][$name] ) ) {
						$resp['headers'][$name] .= ", $val";
					} else {
						$resp['headers'][$name] = $val;
					}
				}
			}
			return $len;
		},
	] );
	try {
		$ret = curl_exec( $ch );
		if ( $ret === false ) {
			throw new Exception( curl_error( $ch ) );
		}
		$resp['body'] = $ret;
		return $resp;
	} finally {
		curl_close( $ch );
	}
}

/**
 * Copyright 2020 Timo Tijhof <https://timotijhof.net>
 *
 * This is free and unencumbered software released into the public domain.
 */
class Unit {
	static $i = 0;
	static $pass = true;

  public static function verbose( $line ) {
    if ( @$_SERVER['DEBUG'] !== '0' ) {
      print $line;
    }
  }

  public static function always( $line ) {
    if ( @$_SERVER['DEBUG'] !== '0' ) {
      print "\n";
    }
    print $line;
  }

	public static function start() {
		error_reporting( E_ALL );
		self::verbose( "TAP version 13\n" );
	}

	public static function test( $name, $actual, $expected ) {
		$num = ++self::$i;
		if ( $actual === $expected ) {
      self::verbose( "ok $num $name\n" );
		} else {
			self::$pass = false;
			self::always( "not ok $num $name\n  ---\n  actual:   "
				. json_encode( $actual, JSON_UNESCAPED_SLASHES ) . "\n  expected: "
				. json_encode( $expected, JSON_UNESCAPED_SLASHES ) . "\n" );
		}
	}

  /**
   * testHttp( 'https://example.org', '/foo' );
   * testHttp( 'example.org', 'http://something.test/foo' );
   * testHttp( 'http://something.test/foo', null );
   *
   * @param string $server Origin, hostname (if path is full URL), or full URL (if path is null)
   * @param string $path|null
   * @param string $reqHeaders
   * @param string $expectHeaders
   */
	public static function testHttp( $server, $path, array $reqHeaders, array $expectHeaders ) {
    if ( $path === null ) {
      $message = $server;
      $parts = parse_url( $server );
      $server = $parts['scheme'] . '://' . $parts['host'];
      $path = $parts['path'] . ( ( $parts['query'] ?? '' ) !== '' ? '?' . $parts['query'] : '' );
    } elseif ( !str_starts_with( $path, '/' ) ) {
      $message = $path;
      $parts = parse_url( $path );
      $reqHeaders[] = 'Host: ' . $parts['host'];
      $server = $parts['scheme'] . '://' . $server;
      $path = $parts['path'] . ( ( $parts['query'] ?? '' ) !== '' ? '?' . $parts['query'] : '' );
    } else {
      $message = $server . $path;
    }
		try {
			$resp = jq_req( $server . $path, $reqHeaders );
			foreach ( $expectHeaders as $key => $val ) {
				// Tolerate E-Tag weakning (which Highwinds CDN does)
				if ( $key == 'etag' ) {
					$actualVal = @$resp['headers'][$key];
					if ( $val !== $actualVal && $actualVal === "W/$val" ) {
						$val = "W/$val";
					}
					if ( $val !== $actualVal && $val === "W/$actualVal" ) {
						$actualVal = "W/$actualVal";
					}
				}

				self::test( "GET $message > header $key", @$resp['headers'][$key], $val );
			}
		} catch ( Exception $e ) {
			self::test( "GET $message > error", $e->getMessage(), null );
		}
	}

	public static function end() {
    self::verbose( '1..' . self::$i . "\n" );
		if ( !self::$pass ) {
			exit( 1 );
		}
	}
}
