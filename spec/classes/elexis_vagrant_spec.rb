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

describe 'elexis::vagrant' do
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(0) }
  end
end

describe 'elexis::vagrant' do
  context 'when running with default parameters' do
    let(:params) { {:ensure => 'true',}}
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(2) }
    it { should contain_file('/home/vagrant').with_ensure('directory') }
    it { should contain_vcsrepo('/home/vagrant/elexis-vagrant') }
  end
end
