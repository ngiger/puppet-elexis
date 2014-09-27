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
  $ensure                 = false
  $enfore_puppet_version  = '3.6.*'           # Upgrading to 3.7. will break many things, i suspect
  $db_type                = 'mysql'           # mysql or pg for postgresql
  $main_user              = 'elexis'          # OS-Usersname for backups, etc
  $db_main                = 'elexis'          # Name of DB to use for production
  $db_test                = 'test'            # Name of test DB to use for production
  $db_password            = 'elexisTest'      # password of main DB user
  $db_pw_hash             = ''                # or better and used if present password hash of main DB user
  $java                   = 'openjdk-7-jdk'
  $bin_dir                = '/usr/local/bin'  # where we will put our binary helper scripts
  $service_path           = '/var/lib/service'
  $jenkins_root           = '/opt/jenkins'
  $download_dir           = '/opt/downloads'
  $download_url           = 'http://ftp.medelexis.ch/downloads_opensource'
  $jenkins_downloads      = '/opt/jenkins/downloads'
  $jenkins_jobs_dir       = '/opt/jenkins/jobs'
  $elexis_base_url        = 'http://hg.sourceforge.net/hgweb/elexis'
  $create_service_script  = "${::elexis::params::bin_dir}/create_service.rb"
  $dest_zip               = "${::elexis::params::download_dir}/floatflt.zip"
  $elexis_file_server     = 'http://ftp.medelexis.ch/downloads_opensource'
  $samba_base             = '/home/samba'
  $main_allow_sudo_all    = true
  $elexis_main            = {
                              name        => 'elexis',
                              mandant     => true,
                              ensure      => present,
                              uid         => '1300',
                              gid         => '1300',
                              group       => 'elexis',
                              groups      => [ dialout, cdrom, plugdev, netdev, adm, sudo, ssh ],
                              comment     => 'Elexis User for Database and backup',
                              managehome  => true,
                              password    => 'elexisTest', # if nil it will not be set
                              shell       => '/bin/bash',
                            }
  $user_definition        =  [ {  name        => 'arzt',
                                  mandant     => true,
                                  ensure      => 'present', # will remove /home/arzt! (possible values absent, present, role)
                                  uid         => '1301',
                                  gid         => '1301',
                                  comment     => 'Dr. Max Mustermann',
                                  groups      => [ dialout, cdrom, elexis, plugdev, netdev, adm, sudo, ssh ],
                                  managehome  => true,
                                  password    => 'elexisTest', # if nil it will not be set
                                  shell       => '/bin/bash',
                                }
                              ]
}

