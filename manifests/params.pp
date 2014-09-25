# == Class: elexis
#
# This is a base class that can be used to modify catalog-wide settings relating
# to the various types in class contained in the elexis module.
#
# If you don't declare this class in your catalog sensible defaults will
# be used.  However if you choose to declare it it needs to appear *before*
# any other types or classes from the elexis module.
#
# For examples see the files in the `tests` directory; in particular
# `/pg_server.pp`.
#
#


class elexis::params {
  $db_type                = 'mysql'           # mysql or pg for postgresql
  $main_user              = 'elexis'          # OS-Usersname for backups, etc
  $db_main                = 'elexis'          # Name of DB to use for production
  $db_test                = 'test'            # Name of test DB to use for production
  $db_password            = 'elexisTest'      # password of main DB user
  $db_pw_hash             = ''                # or better and used if present password hash of main DB user
  $java                   = 'openjdk-7-jdk'
  $binDir                 = '/usr/local/bin'  # where we will put our binary helper scripts
  $service_path           = '/var/lib/service'
  $jenkinsRoot            = '/opt/jenkins'
  $downloadDir            = '/opt/downloads'
  $downloadURL            = 'http://ftp.medelexis.ch/downloads_opensource'
  $jenkinsDownloads       = '/opt/jenkins/downloads'
  $jenkinsJobsDir         = '/opt/jenkins/jobs'
  $elexisBaseURL          = 'http://hg.sourceforge.net/hgweb/elexis'
  $create_service_script  = "${::elexis::params::binDir}/create_service.rb"
  $destZip                = "${::elexis::params::downloadDir}/floatflt.zip"
  $elexisFileServer       = 'http://ftp.medelexis.ch/downloads_opensource'
}

