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

describe 'elexis::samba' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
  end
  context 'when running with default parameters' do
    let(:params) { {:ensure => 'present', }}
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_package('cups-pdf').with_ensure('present') }
    it { should contain_package('cups-bsd').with_ensure('present') }
    it { should contain_package('augeas-tools').with_ensure('present') }
    it { should contain_file('/usr/local/bin/cups-pdf-renamer') }
    it { should contain_file('/opt/samba/elexis/neu').with_ensure('directory') }
    it { should contain_file('/etc/samba/smb.conf') }
    it { should contain_exec('/etc/samba/smb.conf.tested') }
    it { should contain_service('samba') }
  end
  
  context 'when running with parameters from mustermann' do
    let(:params) { {:ensure => 'present', }}
    let :samba do
      {
        :server     =>  { :interfaces => 'eth0' },
      }
    end
    it { should compile }
    it { should compile.with_all_deps }
xxx = %(  
samba::server::interfaces: eth0
samba::server::workgroup: 'Praxis Elexis'
samba::server::server_string: '%h'

samba::server::security: 'user'

samba::server::passwd_chat: '*Enter\snew\sUNIX\spassword:* %n\n *Retype\snew\sUNIX\spassword:* %n\n .'
samba::server::passwd_program: '/usr/bin/passwd %u'
samba::server::pdc: true
samba::server::shares:
  -
    name: profile
    comment: Benutzerprofile
    path: /home/samba/profile
    read_only: false
    force_create mode: 0600
    force_directory mode: '0700'
    browsable: false
)
  end
end
