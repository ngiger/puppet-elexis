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

describe 'elexis::elexis_installations' do
  let(:hiera_config) { }
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__elexis_installations }
      it { should_not contain_elexis__demodb}
    it { should_not contain_elexis__install}
  end
end

describe 'elexis::elexis_installations' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:facts)  { { :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'} }
  let(:params) { {} }
  context 'when running with params from hiera' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__elexis_installations }
    it { should contain_setpass_cleartext('test') }
    it { should contain_elexis__demoDB('elexis_3_opensource')}
    it { should contain_elexis__install('elexis_3_opensource')}
    it { should contain_file('/usr/local/bin/elexis_3_opensource') }
    it { should contain_file('/usr/share/applications/elexis_3_opensource.desktop') }
    it { should contain_file('/usr/share/icons/hicolor/128x128/apps/elexis_3_opensource.png') }
  end
end
