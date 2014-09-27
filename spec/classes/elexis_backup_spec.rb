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
 /\n5 \*\/4  \* \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.elexis_backup.conf hourly\s+>> \/var\/log\/rsnapshot\/elexis_backup.hourly.log\n/,
 /\n15 23  \* \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.elexis_backup.conf daily\s+>> \/var\/log\/rsnapshot\/elexis_backup.daily.log\n/,
 /\n30 23  \* \* 1  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.elexis_backup.conf weekly\s+>> \/var\/log\/rsnapshot\/elexis_backup.weekly.log\n/,
 /\n45 23  1 \* \*  root ionice -c3 \/usr\/bin\/rsnapshot -c \/etc\/rsnapshot.elexis_backup.conf monthly\s+>> \/var\/log\/rsnapshot\/elexis_backup.monthly.log\n/,
]

CrontabBackup = '/etc/cron.d/rsnapshot_elexis_backup'
describe 'elexis::backup' do
#  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(0) }
    it { should contain_elexis__params }
    it { should_not contain_rsnapshot__crontab('elexis_backup') }
  end
  context 'when running with ensure' do
    let(:params) { { :ensure => true,}}
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_package('rsnapshot')}
    it { should contain_elexis__backup}
    it { should contain_package('rsync')}
    it { should contain_elexis__params }
    it { should contain_rsnapshot__crontab('elexis_backup') }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf') }
    it { should contain_exec('/home').with_command(/mkdir -p \/home/) }
    it { should contain_exec('/opt/backup/pg/dumps').with_command(/mkdir -p \/opt\/backup\/pg\/dumps/) }
    it { should contain_exec('/opt/backup/mysql/dumps').with_command(/mkdir -p \/opt\/backup\/mysql\/dumps/) }
    it { should contain_mkdir_p('/etc') }
    it { should contain_mkdir_p('/opt/backup/mysql/dumps') }
    it { should contain_file(CrontabBackup) }
    it { should contain_file(CrontabBackup).with_content(/ionice -c3/) }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf').with_content(/\nsnapshot_root\t\/opt\/backup\n/) }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf').with_content(/\nbackup\t\/etc\t\.\n/) }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf').with_content(/\nbackup\t\/home\t\.\n/) }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf').with_content(/\nbackup\t\/opt\/backup\/mysql\/dumps\t\.\n/) }
    it { should contain_file('/etc/rsnapshot.elexis_backup.conf').with_content(/\nbackup\t\/opt\/backup\/pg\/dumps\t\.\n/) }
  end
end
