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

describe 'elexis::mysql_server' do
  let(:hiera_config) { }
  let(:facts) { WheezyFacts }
  context 'when running with default parameters' do
    it { should compile }
    it { should have_resource_count(2) }
    it { should contain_user('mysql').with_ensure('present') }
    it { should_not contain_service('mysql-server').with_ensure('present') }
    it { should_not contain_package('mysql-client').with_ensure('present') }
  end
end

describe 'elexis::mysql_server' do
  let(:hiera_config) { }
  let(:node) { 'testhost.example.com' }
  let(:title) { 'demo' }
  let(:facts) { WheezyFacts }
    let(:params) { {
            :ensure     => 'true',
                    }}
  context 'when running under Debian with ensure' do
    mustHavesForDumps = [ /logAction/,
                          /mysql_dump_dir\s+=\s+'\/opt\/backup\/mysql\/dumps'/,
                          /mysql_main_db_name\s+=\s+'elexis'/,
                          /mysql_tst_db_name\s+=\s+'test'/,
                          /mysql_main_db_user\s+=\s+'elexis'/,
                          /mysql_main_db_password\s+=\s+'elexisTest'/,
                          /\#{mysql_main_db_name}.dump.gz/,
                          ]

    it { should contain_user('mysql').with_ensure('present') }
    it { should contain_class('mysql::server') }
    it { should_not contain_class('mysql::client') }

    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_dump_elexis.rb'). with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_load_main_db.rb').with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_load_test_db.rb').with_content(must) } }

    it { should contain_file('/usr/local/bin/mysql_load_main_db.rb').with_content(/--host localhost \#{mysql_main_db_name}/) }
    it { should contain_file('/usr/local/bin/mysql_load_test_db.rb').with_content(/--host localhost \#{mysql_tst_db_name}/) }

    it { should contain_mysql_database('elexis').with_ensure(/present/) }
    it { should contain_mysql_database('test').with_ensure(/present/) }

    it { should contain_file('/etc/mysql/conf.d/lowercase.cnf').with_content(/\[mysqld\]\nlower_case_table_names=1\n/) }
    it { should contain_exec('/opt/backup/mysql/dumps') }
    it { should_not contain_file('/opt/backup/mysql/backups') }
    it { should_not contain_file('/etc/cron.d/rsnapshot_mysql_server') }
  end
end

describe 'elexis::mysql_server' do
  let(:hiera_config) { }
  let(:node) { 'testhost.example.com' }
  let(:title) { 'demo' }
  let(:facts) { WheezyFacts }
    let(:params) { {
            :ensure                  => 'true',
            :mysql_main_db_name      =>'db_main',
            :mysql_main_db_user      =>'db_user',
            :mysql_main_db_password  =>'db_password',
            :mysql_tst_db_name       =>'db_test',
            :mysql_dump_dir          =>'/backup/mysql/dumps',
            :root_password           =>'root_password',
            :dump_crontab_params  => { 'minute' => 6, 'hour' => 23, 'user' => 'pg' },
                    }}
  context 'when running under Debian with changed parameters' do
    mustHavesForDumps = [ /logAction/,
                          /mysql_dump_dir\s+=\s+'\/backup\/mysql\/dumps'/,
                          /mysql_main_db_name\s+=\s+'db_main'/,
                          /mysql_tst_db_name\s+=\s+'db_test'/,
                          /mysql_main_db_user\s+=\s+'db_user'/,
                          /mysql_main_db_password\s+=\s+'db_password'/,
                          /\#{mysql_main_db_name}.dump.gz/,
                          ]

    it { should contain_user('mysql').with_ensure('present') }
    it { should contain_class('mysql::server') }
    it { should_not contain_class('mysql::client') }

    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_dump_elexis.rb'). with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_load_main_db.rb').with_content(must) } }
    mustHavesForDumps.each{ |must| it { should contain_file('/usr/local/bin/mysql_load_test_db.rb').with_content(must) } }

    it { should contain_file('/usr/local/bin/mysql_load_main_db.rb').with_content(/--host localhost \#{mysql_main_db_name}/) }
    it { should contain_file('/usr/local/bin/mysql_load_test_db.rb').with_content(/--host localhost \#{mysql_tst_db_name}/) }

    it { should contain_mysql_database('db_main').with_ensure(/present/) }
    it { should contain_mysql_database('db_test').with_ensure(/present/) }

    it { should contain_file('/etc/mysql/conf.d/lowercase.cnf').with_content(/\[mysqld\]\nlower_case_table_names=1\n/) }
    it { should contain_exec('/backup/mysql/dumps') }
    it { should contain_cron('mysql_dump').with_command(/ionice -c3 \/usr\/local\/bin\/mysql_dump_elexis.rb/) }
    it { should contain_cron('mysql_dump').with_minute(6  ) }
    it { should contain_cron('mysql_dump').with_hour(23) }
    it { should contain_cron('mysql_dump').with_user('pg') }
    it { should_not contain_file('/etc/cron.d/rsnapshot_mysql_server') }
  end
end
