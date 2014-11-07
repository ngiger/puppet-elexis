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
    it { should have_resource_count(2) }
    it { should contain_file('/etc/ssh').with_mode('0600') }
  end

  context 'when running with ensure true' do
    let(:params) { { :ensure => true } }
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_file('/etc/ssh').with_mode('0600') }
    it { should_not contain_exec('set_default_editor') }
#    it { should have_resource_count(NrResourcesInElexisCommon) }
  end
end

describe 'elexis::admin' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:facts)  { { :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian', :vagrant => 1} }
    let(:params) { {
            :ensure                  => 'true',
            :pg_util_rb => '/test/bin/pg_util.rb',
            :packages   => ['fish'],
                    }}
  SetEditorCommon = 'update-alternatives --set editor /usr/bin'
  context 'when running with changed parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__admin }
    it { should contain_exec('set_timezone_zurich') }
    it { should contain_exec('set_default_editor').with_command("#{SetEditorCommon}/vim") }
#    it { should contain_file('/etc/hiera.yaml').with_content(/^\s+:datadir: '\/etc\/puppet\/hiera-example-practice'\s*$/) }
#    it { should contain_file('/etc/hiera.yaml').with_source('/etc/puppet/hiera.yaml') }
    it { should contain_file('/usr/local/bin/halt.sh') }
    it { should contain_file('/usr/local/bin/reboot.sh') }
    it { should contain_file('/etc/ssh').with_mode('0600') }
  end
  context 'when running with with vim-nox' do
    let(:hiera_config) { }
    let(:params) { { :ensure => 'true', :editor_package => 'vim-nox'}}
    it { should compile.with_all_deps }
    it { should contain_exec('set_default_editor').with_command("#{SetEditorCommon}/vim.nox") }
  end
  context 'when running with with joe' do
    let(:hiera_config) { }
    let(:params) { { :ensure => 'true', :editor_package => 'joe'}}
    it { should compile.with_all_deps }
    it { should contain_exec('set_default_editor').with_command("#{SetEditorCommon}/joe") }
  end
end
