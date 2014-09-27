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

describe 'elexis::awesome' do
  context 'when running with default parameters' do
    it { should compile.with_all_deps }
  end
end

describe 'elexis::awesome' do
  context 'when running under Debian with ensure' do
    let(:params) { { :ensure => true,}}
    it { should contain_package('awesome') }
    it { should contain_elexis__params }
    it { should contain_elexis__awesome }
    it { should contain_package('awesome') }
    it { should contain_package('xserver-xorg') }
    it { should contain_package('slim') }
    it { should contain_service('slim') }
  end
end

