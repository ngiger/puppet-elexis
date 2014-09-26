# Here we define all needed stuff to bring up a complete
# encoding: utf-8
# mysql-server environment for Elexis
# as per version 2.3 we can specify almost anything as parameter to the mysql::server class
# 
class elexis::mysql_server(
  $ensure                  = false,
  $mysql_main_db_name      = 'elexis',
  $mysql_main_db_user      = 'elexis',
  $mysql_main_db_password  = 'elexisTest',
  $mysql_tst_db_name       = 'test',
  $backup_hourly           = '5 */4', # every 4 hours
  $backup_daily            = '15 23',
  $backup_weekly           = '30 23',
  $backup_monthly          = '45 23',
  $mysql_dump_dir          = '/opt/backup/mysql/dumps',
  $mysql_backup_dir        = '/opt/backup/mysql/backups',
  $root_password           = 'elexisTest',
  $users                   = {
    'elexis@localhost' =>
      {
      ensure                   => 'present',
      max_connections_per_hour => '0',
      max_queries_per_hour     => '0',
      max_updates_per_hour     => '0',
      max_user_connections     => '0',
      # password_hash for a MySQL user in the puppetlabs-mysql Puppet Forge module, run
      # mysql -s -e "SELECT PASSWORD('elexisTest');"
      password_hash            => '*0B9FC6091D135BD4050DDBCA19FC9F73D7527C8B',
      },
    'elexis@%' =>
      {
      ensure                   => 'present',
      password_hash            => '*0B9FC6091D135BD4050DDBCA19FC9F73D7527C8B',
      },
    'reader@localhost' =>
      {
      ensure                   => 'present',
      password_hash            => '*0B9FC6091D135BD4050DDBCA19FC9F73D7527C8B',
      },
    'reader@%' =>
      {
      ensure                   => 'present',
      password_hash            => '*0B9FC6091D135BD4050DDBCA19FC9F73D7527C8B',
      },
  },
  $grants = {
  'elexis@localhost/elexis.*' => {
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'elexis.*',
    user       => 'elexis@localhost',
  },
  'elexis@localhost/test.*' => {
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'test.*',
    user       => 'elexis@localhost',
  },
  'reader@localhost/elexis.*' => {
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'elexis.*',
    user       => 'reader@localhost',
  },
  'reader@localhost/test.*' => {
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'test.*',
    user       => 'reader@localhost',
  },
},
) inherits elexis::params {
  ensure_resource('user', 'mysql', { ensure => present})
  $mysql_dump_script       = '/usr/local/bin/mysql_dump_elexis.rb'
  $mysql_load_main_script  = '/usr/local/bin/mysql_load_main_db.rb'
  $mysql_load_test_script  = '/usr/local/bin/mysql_load_test_db.rb'

  if ($ensure){
    class { '::mysql::server':
        root_password => $root_password,
        users         => $users,
        grants        => $grants,
    }
    #  mysql_grant{$grants: }

    if $mysql_main_db_name {
      mysql_database { $mysql_main_db_name:
        ensure  => 'present',
        charset => 'utf8',
        require => Class['mysql::server'],
      }
    }

    if $mysql_tst_db_name {
      mysql_database { $mysql_tst_db_name:
        ensure  => 'present',
        charset => 'utf8',
        require => Class['mysql::server'],
      }
    }

    $lowercase_conf = '/etc/mysql/conf.d/lowercase.cnf'
    file {$lowercase_conf:
      ensure  => present,
      content => "[mysqld]\nlower_case_table_names=1\n",
      owner   => root,
      group   => root,
      mode    => '0644',
      require => File['/etc/mysql/conf.d/'],
      before  => File[$mysql::params::config_file],
    }

    file {$mysql_dump_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/mysql_common.rb.erb', 'elexis/mysql_dump_elexis.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }

    file {$mysql_load_main_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/mysql_common.rb.erb', 'elexis/mysql_load_main_db.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }

    file {$mysql_load_test_script:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/mysql_common.rb.erb', 'elexis/mysql_load_tst_db.rb.erb'),
      require => File[$elexis::admin::pg_util_rb],
    }

    exec { $mysql_backup_dir:
      command => "mkdir -p ${mysql_backup_dir}",
      path    => '/usr/bin:/bin',
      creates => $mysql_backup_dir
      }

    rsnapshot::crontab{'mysql_server':
      name         => 'mysql_server',
      excludes     => [],
      includes     => [$mysql_dump_dir],
      destination  => $mysql_backup_dir,
      time_hourly  => $backup_hourly,
      time_daily   => $backup_daily,
      time_weekly  => $backup_weekly,
      time_monthly => $backup_monthly,
    }

    file { [ $mysql_dump_dir, $mysql_backup_dir]: #  $mysql_backup_dir not needed as already declared in modules/mysql/manifests/backup.pp:70
      ensure  => directory,
      mode    => '0775',
      recurse => true,
    }
  }
}
