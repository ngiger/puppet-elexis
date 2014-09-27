notice('test: elexis::postgresql_server')
class {'elexis::postgresql_server':
      ensure               => 'true',
      pg_main_db_name      =>'db_main',
      pg_main_db_user      =>'db_user',
      pg_main_db_password  =>'db_password',
      pg_tst_db_name       =>'db_test',
      pg_dump_dir          =>'/backup/pg/dumps',
      pg_backup_dir        =>'/backup/pg/backups',
      pg_dbs               => [
        {
          db_name => 'db_main',
          db_user => 'db_user',
          db_password => 'db_password',
          db_privileges => 'ALL',
        },
        {
          db_name => 'db_test',
          db_user => 'db_user',
          db_password => 'db_password',
          db_privileges => 'ALL',
        },
        {
          db_name => 'db_main',
          db_user => 'reader',
          db_password => 'db_password',
          db_privileges => 'CONNECT',
        },
        {
          db_name => 'db_test',
          db_user => 'reader',
          db_password => 'db_password',
          db_privileges => 'CONNECT',
        }, ]
}

