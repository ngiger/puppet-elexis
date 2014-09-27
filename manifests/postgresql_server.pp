# Here we define all needed stuff to bring up a complete
# PostgreSQL server environment for Elexis
# https://puppetlabs.com/blog/module-of-the-week-inkling-postgresql/
# github: https://github.com/puppetlabs/puppet-postgresql 

# with the default values you can afterward connect as follows to the DB
# psql elexis -U elexis -h localhost --password  # pw is elexisTest

class elexis::postgresql_server(
  $ensure               = absent,
  $pg_main_db_name      = $::elexis::params::db_main,
  $pg_main_db_user      = $::elexis::params::db_user,
  $pg_main_db_password  = $::elexis::params::db_password,
  $pg_tst_db_name       = $::elexis::params::db_test,
  $pg_dump_dir          = '/opt/backup/pg/dumps',
  $dump_crontab_params  = { minute => 5 }, # dump every hour 5 minutes after the full hour
  $ionice               = 'ionice -c3',
  $pg_group             = 'postgres',
  $pg_user              = 'postgres',
  $pg_hba_allow_network = '192.168.1.0/24',
  $pg_setup_hot_sync    = false,                    # not yet finished remote hotsync
  $pg_backup_dir        = '/opt/backup/pg/backups',
  $pg_dbs               = [
    {
      db_name => $::elexis::params::db_main,
      db_user => $::elexis::params::db_user,
      db_password => $::elexis::params::db_password,
      db_privileges => 'ALL',
      encoding => 'utf-8',
      locale => '  de_CH',
    },
    {
      db_name => $::elexis::params::db_test,
      db_user => $::elexis::params::db_user,
      db_password => $::elexis::params::db_password,
      db_privileges => 'ALL',
      encoding => 'utf-8',
      locale => '  de_CH',
    },
    {
      db_name => $::elexis::params::db_main,
      db_user => 'reader',
      db_password => $::elexis::params::db_password,
      db_privileges => 'CONNECT',
      encoding => 'utf-8',
      locale => '  de_CH',
    },
    {
      db_name => $::elexis::params::db_test,
      db_user => 'reader',
      db_password => $::elexis::params::db_password,
      db_privileges => 'CONNECT',
      encoding => 'utf-8',
      locale => '  de_CH',
    },
  ],
  $version              = '9.1',
) inherits elexis::params {
  include elexis::admin
  $pg_dump_script       = '/usr/local/bin/pg_dump_elexis.rb'
  $pg_load_main_script  = '/usr/local/bin/pg_load_main_db.rb'
  $pg_load_test_script  = '/usr/local/bin/pg_load_test_db.rb'
  $pg_util_script       = '/usr/local/bin/pg_util.rb'
  $pg_poll_script       = '/usr/local/bin/pg_poll.rb'
  $pg_fill_script       = '/usr/local/bin/pg_fill.rb'
  $pg_archive_wal_script= '/usr/local/bin/pg_archive_wal.sh'

  unless ($ensure == absent) {
    class { 'postgresql::globals':
      manage_package_repo => true,
      encoding            => 'UTF8',
      locale              => 'de_CH.UTF-8',
      version             => $version,
    }
    class { 'postgresql::server':
      listen_addresses => '*',
    }
    include concat::setup
    include postgresql::client
    
    user{'postgres':
      require => Package[$postgresql::params::client_package_name],
    }
    group{'postgres':
      require => Package[$postgresql::params::client_package_name],
    }
    
    file  { '/var/lib/postgresql/.ssh/':
      ensure  => directory,
      owner   => $pg_user,
      group   => $pg_group,
      mode    => '0700',
      require => Service[postgresqld],
    }
    exec{'/var/lib/postgresql/.ssh/id_rsa':
      creates => '/var/lib/postgresql/.ssh/id_rsa',
      command => "/usr/bin/ssh-keygen -N '' -f /var/lib/postgresql/.ssh/id_rsa",
      user    => $pg_user,
      require => File['/var/lib/postgresql/.ssh/'],
    }
    
    elexis::pg_dbusers{$pg_dbs:}
    if ($pg_setup_hot_sync == true) {
      
    elexis::mkdir_p{"${pg_backup_dir}/wal": }
    file  { "${pg_backup_dir}/wal/":
      ensure => directory,
      owner  => $pg_user,
      group  => $pg_group,
      mode   => '0775',
      require => Elexis::Mkdir_p["${pg_backup_dir}/wal"]
    }
    package { 'postgresql-contrib':
      ensure => present,
      }

    # now comes the whole setup for online backup on server and backup
    if ($::hostname== 'server') {
      $backup_partner       = 'backup'
      $backup_dir           = '/opt/backups_from_backup'
      $reverse_backup_dir   = '/opt/backups_from_server'
    } else { if ($::hostname== 'backup') {
      $backup_partner       = 'server'
      $backup_dir           = '/opt/backups_from_server'
      $reverse_backup_dir   = '/opt/backups_from_backup'
    } else  {
      notify{"host ${::hostname} is neither backup nor server": }
    } }
    # notify{"pg: wal $backup_dir $reverse_backup_dir": }
    if ($backup_dir != '')  {
      # notify{"pg: Creating $backup_dir $reverse_backup_dir": }
      sshd_config { 'PermitEmptyPasswords':
        ensure    => present,
        condition => "Host ${backup_partner}",
        value     => 'yes',
      }
      
      file {[$backup_dir]:
        ensure => directory,
      }
      
      if $reverse_backup_dir {
        file { $reverse_backup_dir:
          ensure => directory,
        }
      }
      
      file { "${backup_dir}/wal":
        ensure  => directory,
        require => File[$backup_dir],
      }
      
    }
    file {$pg_archive_wal_script:
      ensure => present,
      source => 'puppet:///modules/elexis/pg_archive_wal.sh',
      owner  => 'postgres',
      group  => 'postgres',
      mode   => '0744',
    }
      
    # $config_hash = hiera('pg::config_hash', '')
    $conf_dir    = $postgresql::params::confdir
    $archive_timeout = hiera('pg::pg_archive_timeout', '600') # by default every 10 minutes = 600 seconds
    # template("elexis/postgresql_puppet_extras.conf.erb"),
    file {"${conf_dir}/postgresql_puppet_extras.conf":
      content => "# managed by puppet. see elexis/manifests/postgresql_server.pp
  #archive_command = '/usr/bin/test ! -f ${backup_dir}/wal/%f && /bin/cp %p ${reverse_backup_dir}/%f < /dev/null'
  #archive_timeout = ${archive_timeout}
  autovacuum =      on
  ",
    }
    }

    if ($pg_hba_allow_network) {
      postgresql::server::pg_hba_rule { 'allow application network to access all database from the local network':
        description => 'Open up postgresql for access from localhost',
        type        => 'host',
        database    => 'all',
        user        => 'all',
        address     => $pg_hba_allow_network,
        auth_method => 'md5',
      }
    }
    postgresql::server::pg_hba_rule { 'allow application network to access all database from localhost':
      description => 'Open up postgresql for access from localhost',
      type        => 'host',
      database    => 'all',
      user        => 'all',
      address     => '127.0.0.1/32',
      auth_method => 'md5',
    }
    
    if ($pg_dump_dir) {

    file {$pg_dump_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_common.rb.erb', 'elexis/pg_dump_elexis.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }

    file {$pg_fill_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_common.rb.erb', 'elexis/pg_fill.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }
    
    file {$pg_load_test_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_common.rb.erb', 'elexis/pg_load_tst_db.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }
    
    file {$pg_load_main_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_common.rb.erb', 'elexis/pg_load_main_db.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }
    
    file {$pg_poll_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_common.rb.erb', 'elexis/pg_poll.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }

    elexis::mkdir_p{$pg_backup_dir: }
    file { $pg_backup_dir :
      ensure  => directory,
      mode    => '0755',
      recurse => true,
      owner   =>  $::postgresql::params::user,
      group   => $::postgresql::params::group,
      require => Elexis::Mkdir_p[$pg_backup_dir],
    }
      
    elexis::mkdir_p{$pg_dump_dir: }
    file { $pg_dump_dir :
      ensure  => directory,
      mode    => '0755',
      recurse => true,
      owner   =>  $::postgresql::params::user,
      group   => $::postgresql::params::group,
      require => Elexis::Mkdir_p[$pg_dump_dir],
    }
      
    ensure_resource('cron', 'pg_dump',
      merge( {
        ensure  => present,
        command => "${ionice} ${pg_dump_script} >>/var/log/pg_dump.log 2>&1",
        user    => $pg_user,
        require => File[$pg_dump_script, $pg_dump_dir],
        }, $dump_crontab_params
      )
    )

    file {'/etc/cron.weekly/pg_load_test_script.rb':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File[$pg_load_test_script],
      content => "#!/bin/sh
  test -x ${pg_load_test_script} || exit 0
  ${pg_load_test_script}  >/var/log/pg_load_test.log 2>&1
  "
    }
    
    file {'/etc/logrotate.d/pg_elexis_dump':  ensure => absent}
    }
  }
}

#  define a single database users
#  more ist not to be said
define elexis::pg_dbuser(
  $db_user,
  $db_name,
  $db_privileges  = 'ALL',
  $db_pw_hash  = '',
  $db_password = '',
) {
  if !defined(Postgresql::Server::Role[$db_user]) {
    postgresql::server::role{$db_user:
      login         => true,
      password_hash => postgresql_password($db_user, $db_password),
      require       => Service[postgresqld],
    }
  }
  
  if !defined(Postgresql::Server::Db[$db_name]) {
    postgresql::server::db{$db_name:
      user     => $db_user,
      password => $db_password,
      encoding => 'utf-8',
      locale   => 'de_CH.UTF-8',
    }
  }

  $grant_id = "GRANT ${db_user} - ${db_privileges} - ${db_name}"
  if !defined(Postgresql::Server::Database_grant[$grant_id]) {
    # == postgresql::server::database_grant
    # grant a privilege
    postgresql::server::database_grant{$grant_id:
      privilege => $db_privileges,
      db        => $db_name,
      role      => $db_user,
      require   => [
        Postgresql::Server::Role[$db_user],
        Postgresql::Server::Db[$db_name],
        Service[postgresqld],
      ]
    }
  }
}

#  define all database users
#  more ist not to be said
define elexis::pg_dbusers(
) {
  include elexis::postgresql_server
  $db_name =  $title[db_name]
  $db_pw_hash =  $title[db_pw_hash]
  $db_user =  $title[db_user]
  $db_password =  $title[db_password]
  $db_privileges = $title[db_privileges]
  $pg_db_user = "${db_name}_${db_user}"

  # notice("elexis::pg_dbusers $db_name user $db_user $pg_db_user params db_user ${::elexis::params::db_user}")
  elexis::pg_dbuser{$pg_db_user:
    db_name       => $db_name,
    db_user       => $db_user,
    db_password   => $db_password,
    db_pw_hash    => $db_pw_hash,
    db_privileges => $db_privileges,
  }
}

