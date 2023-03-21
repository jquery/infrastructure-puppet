# @summary installs and manages a wordpress blog
# @param $host main host name of this blog
# @param $certificate lets encrypt certificate name
# @param $db_password_seed seed to use to generate a database password
define wordpress::site (
  Stdlib::Fqdn $host,
  String[1]    $certificate,
  String[1]    $db_password_seed,
) {
  mariadb::database { "wordpress_${title}": }

  $db_user_password = jqlib::autogen_password($title, $db_password_seed)

  mariadb::user { "wordpress_${title}":
    host => '127.0.0.1',
    auth => { password => $db_user_password },
  }

  mariadb::grant { "wordpress_${title}":
    user_name => "wordpress_${title}",
    user_host => '127.0.0.1',
    database  => "wordpress_${title}",
    grants    => { all => true },
  }

  exec { "wp-download-${title}":
    command   => "/usr/local/bin/wp core download --path=/srv/wordpress/${title}",
    creates   => "/srv/wordpress/${title}",
    user      => 'www-data',
    require   => File['/usr/local/bin/wp'],
    logoutput => true,
  }

  exec { "wp-create-config-${title}":
    command   => "/usr/local/bin/wp config create --dbname=wordpress_${title} --dbuser=wordpress_${title} --dbhost=127.0.0.1 --dbpass=${db_user_password}",
    creates   => "/srv/wordpress/${title}/wp-config.php",
    user      => 'www-data',
    require   => Exec["wp-download-${title}"],
  }
}
