# @define Execute arbitrary SQL against the local MariaDB database.
#   Beware that no attempt is made to sanitize input.
#   Based on the mediawiki-vagrant define: https://github.com/wikimedia/mediawiki-vagrant/blob/master/puppet/modules/mysql/manifests/sql.pp
# @param $sql SQL code to execute
# @param $unless SQL query to determine whether to run the command or not. It should always
#   SELECT 1, and if any rows are returned $sql will not be executed.
define mariadb::command (
  String[1] $sql,
  String[1] $unless,
) {
  exec { $title:
    # Passing input to a shell command in Puppet without it undergoing shell expansion is nasty.
    command => @("PUPPETCOMMAND")
        /usr/bin/mariadb -qsA <<'SQLCOMMAND'
        ${sql}
        SQLCOMMAND
        | PUPPETCOMMAND
    ,
    unless  => @("PUPPETCOMMAND")
        /usr/bin/mariadb -qfsAN <<'SQLCOMMAND' | /usr/bin/tail -1 | /bin/grep -q 1
        ${unless}
        SQLCOMMAND
        | PUPPETCOMMAND
    ,
  }
}
