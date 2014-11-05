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

describe 'elexis::admin' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  let(:hiera_config) { }
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(1) }
  end

  context 'when running with ensure true' do
    let(:params) { { :ensure => true } }
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(NrResourcesInElexisCommon) }
  end
end

describe 'elexis::admin' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:facts)  { { :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'} }
    let(:params) { {
            :ensure                  => 'true',
            :pg_util_rb => '/test/bin/pg_util.rb',
            :packages   => ['fish'],
                    }}
  context 'when running with changed parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__admin }
    it { should contain_exec('set_timezone_zurich') }
    it { should contain_file('/usr/local/bin/halt.sh') }
    it { should contain_file('/usr/local/bin/reboot.sh') }
  end
end
