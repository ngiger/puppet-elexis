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

describe 'elexis::demodb' do
  context 'when running under Debian with ensure' do
  let(:title) { 'demoDB_for_elexis' }
  let(:params) { {:user => 'elexis',}}
    it { should contain_user('elexis').with_ensure('present') }
    it { should contain_file('/home/elexis/elexis').with_ensure('directory') }
    it { should contain_exec('unzip_demodb_for_elexis') }
    it { should contain_exec('wget_demodb') }
  end
end
