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


class elexis::params (
  $ensure                 = false,
  $enfore_puppet_version  = '3.6.*',           # Upgrading to 3.7. will break many things, i suspect
  $db_type                = 'mysql',           # mysql or pg for postgresql
  $backup_user            = 'backup_user',     # OS-Usersname for backups, etc
  $db_user                = 'db_elexis_user',  # main db user (all privileges for elexis databases)
  $db_main                = 'elexis',          # Name of DB to use for production
  $db_test                = 'test',            # Name of test DB to use for production
  $db_password            = 'elexisTest',      # password of main DB user
  $db_pw_hash             = '',                # or better and used if present password hash of main DB user
  $java                   = 'openjdk-7-jdk',
  $bin_dir                = '/usr/local/bin',  # where we will put our binary helper scripts
  $create_service_script  = "/usr/local/bin/create_service.rb",
  $service_path           = '/var/lib/service',
  $jenkins_root           = '/opt/jenkins',
  $download_dir           = '/opt/downloads',
  $download_url           = 'http://ftp.medelexis.ch/downloads_opensource',
  $jenkins_downloads      = '/opt/jenkins/downloads',
  $dest_zip               = "/opt/jenkins/downloads/floatflt.zip",
  $jenkins_jobs_dir       = '/opt/jenkins/jobs',
  $elexis_base_url        = 'http://hg.sourceforge.net/hgweb/elexis',
  $elexis_file_server     = 'http://ftp.medelexis.ch/downloads_opensource',
  $samba_base             = '/home/samba',
  $main_allow_sudo_all    = true,
  $elexis_main            = 'arzt',
  $add_groups             =  [dialout, cdrom, plugdev, adm, sudo, ssh ], # groups mentioned here may not appear else in the user definition!
  $user_definition        =  { arzt => {
                                  mandant     => true,
                                  ensure      => 'present', # will remove /home/arzt! (possible values absent, present, role)
                                  uid         => '1301',
                                  comment     => 'Dr. Max Mustermann',
                                  groups      => [ dialout, cdrom, plugdev, adm, sudo, ssh ],
                                  managehome  => true,
                                  pw_clear    => 'test', # if nil it will not be set
                                  shell       => '/bin/bash',
                                } ,
                      }
                     )
{ }
