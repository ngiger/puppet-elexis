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

describe 'elexis::samba', :type => :class  do
  let(:facts) { WheezyFacts }
  let(:hiera_config) {  }
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should_not contain_file('/etc/samba/smb.conf.tested') }

  end

  context 'when running with default parameters' do
    let(:params) { {:ensure => 'present', :pdf_ausgabe  => true }}
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_package('cups-pdf').with_ensure('present') }
    it { should contain_package('cups-bsd').with_ensure('present') }
    it { should contain_package('samba').with_ensure('installed') }
    it { should contain_file('/usr/local/bin/cups-pdf-renamer') }
    it { should contain_file('/opt/samba/elexis/neu').with_ensure('directory') }
    it { should contain_file('/etc/samba/smb.conf').with_content(/\n\[pdf-ausgabe\]\n/) }
    it { should contain_file('/opt/samba/elexis').with_ensure('directory') }
    it { should contain_file('/etc/cups/cups-pdf.conf') }
    it { should contain_exec('/etc/samba/smb.conf.tested') }
    it { should contain_service('samba') }
    it { should contain_elexis__common }
    it { should contain_elexis__params }
    it { should contain_elexis__samba }
  end
end

describe 'elexis::samba', :type => :class  do
  context 'when running with parameters from mustermann' do
    let(:params) { {:ensure => 'present',  :pdf_ausgabe  => true, :with_x2go => true }}
    let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_file('/opt/mustermann/samba').with_ensure('directory') }
    it { should contain_file('/etc/samba/smb.conf').with_content(/\n\[pdf-ausgabe\]\n/) }
    it { should contain_file('/etc/samba/smb.conf').with_content(/Praxis Mustermann/) }
    it { should contain_file('/etc/samba/smb.conf').with_content(/Praxis Mustermann/) }
    it { should contain_exec('wget-http://code.x2go.org/releases/X2GoClient_latest_macosx.dmg') }
    it { should contain_exec('wget-http://code.x2go.org/releases/X2GoClient_latest_mswin32-setup.exe') }
    it { should contain_wget__fetch('http://code.x2go.org/releases/X2GoClient_latest_macosx.dmg') }
    it { should contain_wget__fetch('http://code.x2go.org/releases/X2GoClient_latest_mswin32-setup.exe') }
    it { should contain_group('mustermann').with('gid' => '5555',) }
    it { should contain_user('mustermann').with('ensure' => 'present',
                                                'uid' => '5555',
                                                'gid' => '5555',
                                                'shell' => "/bin/dash",
                                                'groups' => [ 'gruppe_1', 'gruppe_2'],
                                                'comment' => "Comment from fixture Mustermann for not_arzt",
                                               ) }
  end

end
