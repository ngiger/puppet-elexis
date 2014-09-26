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

PgCronPatterns = [
 /\n5 \*\/4  \* \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.pg_server.conf hourly\s+>> \/var\/log\/rsnapshot\/pg_server.hourly.log\n/,
 /\n15 23  \* \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.pg_server.conf daily\s+>> \/var\/log\/rsnapshot\/pg_server.daily.log\n/,
 /\n30 23  \* \* 1  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.pg_server.conf weekly\s+>> \/var\/log\/rsnapshot\/pg_server.weekly.log\n/,
 /\n45 23  1 \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.pg_server.conf monthly\s+>> \/var\/log\/rsnapshot\/pg_server.monthly.log\n/,
]
describe 'elexis::postgresql_server' do
  context 'when running with default parameters' do
    it { should compile }
    it { should have_resource_count(0) }
    it { should_not contain_service('postgresql-server').with_ensure('present') }
    it { should_not contain_package('postgresql-client').with_ensure('present') }
  end
end

describe 'elexis::postgresql_server' do
  let(:facts) {{ :osfamily => 'Debian', :operatingsystemrelease => 'wheezy', :lsbdistid => 'debian', :concat_basedir => '/opt/concat' }}
  let(:params) { {
            :ensure     => 'true',
                    }}
  context 'when running under Debian with ensure' do

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

#    it { should contain_postgresql_database('elexis').with_ensure(/present/) }
#    it { should contain_postgresql_database('test').with_ensure(/present/) }

    it { should contain_file('/opt/backup/pg/dumps').with_ensure('directory') }
    it { should contain_file('/opt/backup/pg/backups').with_ensure('directory') }
    it { should contain_file('/etc/cron.d/rsnapshot_pg_server').with_content(/ionice/) }
    PgCronPatterns.each{ |pattern|  it { should contain_file('/etc/cron.d/rsnapshot_pg_server').with_content(pattern) } }

    it { should contain_file('/etc/rsnapshot.pg_server.conf').with_content(/\nbackup\t\/opt\/backup\/pg\/dumps/) }
  end
end

describe 'elexis::postgresql_server' do
  let(:facts) {{ :osfamily => 'Debian', :operatingsystemrelease => 'wheezy', :lsbdistid => 'debian', :concat_basedir => '/opt/concat' }}
  let(:params) { {
            :ensure                  => 'true',
            :pg_main_db_name      =>'db_main',
            :pg_main_db_user      =>'db_user',
            :pg_main_db_password  =>'db_password',
            :pg_tst_db_name       =>'db_test',
            :pg_dump_dir          =>'/backup/pg/dumps',
            :pg_backup_dir        =>'/backup/pg/backups',
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
    
    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/pg_dump --user \#{pg_main_db_user}/) }
    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/cmd \+= pg_main_db_name/) }
    it { should contain_file('/usr/local/bin/pg_dump_elexis.rb').with_content(/--encoding=UTF-8/) }
    it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/) }
    it { should contain_file('/usr/local/bin/pg_load_main_db.rb').with_content(/--host localhost --dbname=\#{pg_main_db_name}/) }
    it { should contain_file('/usr/local/bin/pg_load_test_db.rb').with_content(/--host localhost --dbname=\#{pg_tst_db_name}/) }

#    it { should contain_pg_database('db_main').with_ensure(/present/) }
#    it { should contain_pg_database('db_test').with_ensure(/present/) }

    it { should contain_file('/backup/pg/dumps').with_ensure('directory') }
    it { should contain_file('/backup/pg/backups').with_ensure('directory') }
    it { should contain_file('/etc/cron.d/rsnapshot_pg_server').with_content(/ionice/) }
    PgCronPatterns.each{ |pattern|  it { should contain_file('/etc/cron.d/rsnapshot_pg_server').with_content(pattern) } }
  end
end