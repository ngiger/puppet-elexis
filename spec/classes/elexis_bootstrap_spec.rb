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

describe 'elexis::bootstrap' do
  let(:facts) { WheezyFacts }
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(NrResourcesInElexisCommon) }
    it { should contain_user('elexis') }
    it { should contain_group('elexis') }
    it { should contain_file('/etc/sudoers.d/elexis') }
    it { should contain_file('/opt/downloads') }
  end
  context 'when running under Debian with ensure' do
  let(:params) { {:ensure => true,}}
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_apt__params }
    it { should contain_elexis__bootstrap }
    it { should contain_elexis__common }
    it { should contain_elexis__params }
    it { should contain_exec('bootstrap-elexis-3') }
    it { should contain_exec('update-java-alternatives') }
    it { should contain_java }
    it { should contain_java__config }
    it { should contain_java__params }
    it { should contain_package('eclipse-rcp') }
    it { should contain_package('java') }
    it { should contain_package('mysql-utilities') }
    it { should contain_package('mysql-workbench') }
    it { should contain_package('ruby') }
    it { should contain_vcsrepo('/opt/bootstrap-elexis-3') }
  end
end

