# Here we define all needed stuff to bring up a complete
# encoding: utf-8
# mysql-server environment for Elexis
# as per version 2.3 we can specify almost anything as parameter to the mysql::server class
#
class elexis::mysql_server(
  $ensure                  = false,
  $mysql_main_db_name      = $::elexis::params::db_main,
  $mysql_main_db_user      = $::elexis::params::db_user,
  $mysql_main_db_password  = $::elexis::params::db_password,
  $mysql_tst_db_name       = $::elexis::params::db_test,
  $dump_crontab_params     =  { minute => 5 }, # dump every hour 5 minutes after the full hour
  $ionice                  = 'ionice -c3',
  $mysql_dump_dir          = '/opt/backup/mysql/dumps',
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
  include elexis::admin
  include mysql::params
  $mysql_dump_script       = '/usr/local/bin/mysql_dump_elexis.rb'
  $mysql_load_main_script  = '/usr/local/bin/mysql_load_main_db.rb'
  $mysql_load_test_script  = '/usr/local/bin/mysql_load_test_db.rb'

  if ($ensure){
    ensure_resource('user', 'mysql',  { ensure => present, system => true })
    # Package[$::mysql::params::server_package_name] ~> Group['mysql']
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

    ensure_resource('cron', 'mysql_dump',
      merge( {
        ensure  => present,
        subscribe => [File[$mysql_dump_script], Exec[$mysql_dump_dir],],
        command => "${ionice} ${mysql_dump_script} >>/var/log/mysql_dump.log 2>&1",
        require => [File[$mysql_dump_script], Exec[$mysql_dump_dir],],
        }, $dump_crontab_params
      )
    )

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

    exec { [ $mysql_dump_dir]:
      command => "/bin/mkdir -p $mysql_dump_dir",
      unless => "/usr/bin/test -d $mysql_dump_dir",
    }
  }
}
