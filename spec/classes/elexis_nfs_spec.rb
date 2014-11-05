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

describe 'elexis::nfs' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  let(:hiera_config) { }
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__nfs }
    it { should_not contain_nfs__client }
    it { should_not contain_nfs__server }
  end

  context 'when running with client true' do
    let(:params) { { :client => true } }
    it { should compile }
    it { should contain_elexis__nfs }
    it { should contain_nfs__client }
    it { should_not contain_nfs__server }
  end
  context 'when running with server true' do
    let(:params) { { :server => true } }
    it { should compile }
    it { should contain_elexis__nfs }
    it { should contain_nfs__client }
    it { should contain_nfs__server }
    it { should contain_nfs__exports } # or you cannot defines exports via hiera!
  end
end

describe 'elexis::nfs' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:facts)  { { :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'} }
  context 'when running with params from hiera' do
    it {
      should compile
      should compile.with_all_deps
      should contain_elexis__nfs
      should contain_nfs__client
      should contain_nfs__server
      should contain_nfs__exports  # or you cannot defines exports via hiera!
      should contain_mount('/mnt/1').only_with( {
                                            :ensure => 'absent',
                                            :fstype => 'test_type',
                                            :options => 'defaults,rw',
                                            :atboot => false,
                                            :device => 'localhost:/blubb',
                                            :name => '/mnt/1',
                                            } )
      should contain_service('portmap').with_ensure('running')
      should contain_service('nfs-kernel-server').with_ensure('running')
  }
  end
end
