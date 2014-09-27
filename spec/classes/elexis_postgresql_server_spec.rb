#
#    Copyright (C) 2014 Niklaus Giger <niklaus.giger@member.fsf.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'spec_helper'

describe 'elexis::postgresql_server' do
  let(:facts) { WheezyFacts }
  context 'when running with default parameters' do
    it { should compile }
    it { should have_resource_count(NrResourcesInElexisCommon) }
    it { should_not contain_service('postgresql-server').with_ensure('present') }
    it { should_not contain_package('postgresql-client').with_ensure('present') }
  end
end

describe 'elexis::postgresql_server' do
  let(:facts) { WheezyFacts }
  let(:params) { {
            :ensure     => 'true',
                    }}
  context 'when running under Debian with ensure' do
    let(:facts) { WheezyFacts }

    mustHavesForDumps = [ /logAction/,
                          /ENV\['PGPASSWORD'\] = 'elexisTest'/,
                          /pg_dump_dir\s+=\s+'\/opt\/backup\/pg\/dumps'/,
                          /pg_main_db_name\s+=\s+'elexis'/,
                          /pg_tst_db_name\s+=\s+'test'/,
                          /pg_main_db_password\s+=\s+'elexisTest'/,
                          ]

    it { should contain_user('postgres')   }
    it { should contain_class('postgresql::globals') }
    it { should contain_class('postgresql::server') }
    it { should contain_package('postgresql-client').with_ensure('present') }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_dump_elexis.rb'). with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_load_test_db.rb').with_content(must) } }

    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/pg_dump --user \#{pg_main_db_user}/) }
    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/cmd \+= pg_main_db_name/) }
    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/--encoding=UTF-8/) }
    it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/) }
    it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/) }
    it { should contain_file('/usr/local/bin/pg_load_test_db.rb').with_content(/--host localhost --dbname=\#{pg_tst_db_name}/) }

    it { should contain_postgresql__server__database('elexis') }
    it { should contain_postgresql__server__db('elexis') }
    it { should contain_postgresql__server__database('test') }
    it { should contain_postgresql__server__db('test') }

    it { should contain_postgresql__server__database_grant('GRANT reader - CONNECT - elexis') }
    it { should contain_postgresql__server__database_grant('GRANT elexis - ALL - elexis') }
    it { should contain_postgresql__server__database_grant('GRANT reader - CONNECT - test') }
    it { should contain_postgresql__server__database_grant('GRANT elexis - ALL - test') }

    it { should contain_file('/opt/backup/pg/dumps').with_ensure('directory') }
    it { should contain_file('/opt/backup/pg/backups').with_ensure('directory') }
    it { should_not contain_file('/etc/cron.d/rsnapshot_pg_server') }
    it { should contain_cron('pg_dump').with_command(/ionice -c3 \/usr\/local\/bin\/pg_dump_elexis.rb/) }
    it { should contain_cron('pg_dump').with_minute(5) }
  end
end

describe 'elexis::postgresql_server' do
  let(:facts) { WheezyFacts }
  let(:params) { {
            :ensure               => 'true',
            :pg_main_db_name      =>'db_main',
            :pg_main_db_user      =>'db_user',
            :pg_main_db_password  =>'db_password',
            :pg_tst_db_name       =>'db_test',
            :pg_dump_dir          =>'/backup/pg/dumps',
            :pg_backup_dir        =>'/backup/pg/backups',
            :dump_crontab_params  => { 'minute' => 6, 'hour' => 23, 'user' => 'pg' },
            :pg_dbs               => [
              {
                'db_name' => 'db_main',
                'db_user' => 'db_user',
                'db_password' => 'db_password',
                'db_privileges' => 'ALL',
              },
              {
                'db_name' => 'db_test',
                'db_user' => 'db_user',
                'db_password' => 'db_password',
                'db_privileges' => 'ALL',
              },
              {
                'db_name' => 'db_main',
                'db_user' => 'reader',
                'db_password' => 'db_password',
                'db_privileges' => 'CONNECT',
              },
              {
                'db_name' => 'db_test',
                'db_user' => 'reader',
                'db_password' => 'db_password',
                'db_privileges' => 'CONNECT',
              }, ] 
                    }}
  context 'when running under Debian with changed parameters' do
    mustHavesForDumps = [ /logAction/,
                          /ENV\['PGPASSWORD'\] = 'db_password'/,
                          /pg_dump_dir\s+=\s+'\/backup\/pg\/dumps'/,
                          /pg_main_db_user\s+=\s+'db_user'/,
                          /pg_main_db_name\s+=\s+'db_main'/,
                          /pg_tst_db_name\s+=\s+'db_test'/,
                          /pg_main_db_password\s+=\s+'db_password'/,
                          ]
    it { should contain_user('postgres')   }
    it { should contain_class('postgresql::globals') }
    it { should contain_class('postgresql::server') }
    it { should contain_package('postgresql-client').with_ensure('present') }

    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_dump_elexis.rb'). with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/pg_load_test_db.rb').with_content(must) } }

    it {
     should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/pg_dump --user \#{pg_main_db_user}/)
     should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/cmd \+= pg_main_db_name/)
     should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/--encoding=UTF-8/)
     should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/)
     should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/)
     should contain_file('/usr/local/bin/pg_load_test_db.rb').with_content(/--host localhost --dbname=\#{pg_tst_db_name}/)
    }

    it { should contain_postgresql__server__database('db_main') }
    it { should contain_postgresql__server__db('db_main') }
    it { should contain_postgresql__server__database('db_test') }
    it { should contain_postgresql__server__db('db_test') }

    it { should contain_postgresql__server__database_grant('GRANT db_user - ALL - db_main') }
    it { should contain_postgresql__server__database_grant('GRANT db_user - ALL - db_test') }
    it { should contain_postgresql__server__database_grant('GRANT reader - CONNECT - db_main') }
    it { should contain_postgresql__server__database_grant('GRANT reader - CONNECT - db_test') }
    it { should contain_cron('pg_dump').with_command(/ionice -c3 \/usr\/local\/bin\/pg_dump_elexis.rb/) }
    it { should contain_cron('pg_dump').with_minute(6) }
    it { should contain_cron('pg_dump').with_hour(23) }
    it { should contain_cron('pg_dump').with_user('pg') }

    it { should contain_file('/backup/pg/dumps').with_ensure('directory') }
    it { should contain_file('/backup/pg/backups').with_ensure('directory') }
    it { should_not contain_file('/etc/cron.d/rsnapshot_pg_server') }
  end
end