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

describe 'elexis::common' do
  let(:hiera_config) { }
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(0) }
  end
end
describe 'elexis::common' do
  main_user = 'mustermann'
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  context 'when running with hiera  ' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(NrResourcesInElexisCommon_with_Hiera) }
    it { should contain_apt__params }
    it { should contain_elexis__common }
    it { should contain_elexis__params }
    it { should contain_file('/opt/downloads').with_ensure('directory').with_owner(main_user).with_group(main_user) }
    it { should contain_file('/etc/sudoers.d/mustermann').with_mode('0440') }
    it { should contain_user(main_user) }
    it { should contain_group(main_user) }
  end
end
