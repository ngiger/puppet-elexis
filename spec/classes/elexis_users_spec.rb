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

describe 'elexis::users' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  let(:hiera_config) { }
  context 'when running under Debian with defaults' do
    let(:title) { 'defaults' }
    it { should_not contain_group }
    it { should_not contain_user }
  end
end

describe 'elexis::users' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:params) { { }}
  context 'when running with hiera parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_file('/etc/sudoers.d/mustermann').with_content(/mustermann ALL=NOPASSWD:ALL/) }
    it { should contain_file('/opt/downloads').with_ensure('directory').with_owner('mustermann') }
    it { should contain_file('/home/arzt2').only_with( {:ensure => 'absent', :force => true, :recurse => true, :path => '/home/arzt2' } ) }
    it {
      should contain_group('system_group_1').with_system('true')
      should contain_group('system_group_2').with_system('true')
      should contain_group('gruppe_1')
      should contain_group('gruppe_2')
      should contain_group('gruppe_3')
      should contain_group('arzt1')
      should contain_group('arzt2')
      should contain_group('mpa')
      should contain_group('mpa2')
      should contain_group('mustermann')
      should contain_user('arzt1')
      should contain_user('arzt2')
      should contain_user('mpa')
      should contain_user('mpa2')
      should contain_user('mustermann')
      should contain_exec('set_passwd_mustermann')
      should_not contain_exec('set_passwd_mpa')
      should contain_setpass_hash('mpa')
      should contain_setpass_cleartext('mustermann')
    }
  end
end
