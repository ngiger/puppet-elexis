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

describe 'elexis::windows' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should_not contain_package('wine') }
    it { should_not contain_package('xvfb') }
  end
end

describe 'elexis::windows' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    let(:params) { {:ensure => 'true',}}
#    it { should compile }
#    it { should compile.with_all_deps }
    it { should contain_package('wine') }
    it { should contain_package('xvfb') }
    it { should contain_wget__fetch('http://download.java.net/openjdk/jdk7/promoted/b146/gpl/openjdk-7-b146-windows-i586-20_jun_2011.zip') }
    it { should contain_exec('/home/samba/elexis-windows/current') }
    it { should contain_exec('unzip_/home/samba/java-se-7-ri/bin/java.exe') }
    it { should contain_elexis__unzip('unzip_open_jdk_wine').with_dest('/home/samba/java-se-7-ri/bin/java.exe') }    
  end
end
