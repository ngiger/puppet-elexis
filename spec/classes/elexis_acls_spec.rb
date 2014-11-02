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

describe 'elexis::acls' do
  context 'when running with default parameters' do
    it { should compile.with_all_deps }
    it { should_not contain_fooacl }
    it { should contain_elexis__acls }
  end
end

describe 'elexis::acls' do
  context 'when running under Debian with configured acls' do
     let(:params) { { :conf => { '/var/www' => { 'permissions' => ['user:backup:r-X', 'user:www-data:rwX' ] },
                                 '/data'    => { 'permissions' => ['user:backup:r-X', 'user:www-data:rwX' ] }
                                 } } }
    it { should contain_fooacl }
    it { should contain_fooacl__Conf('/data_user:backup:r-Xuser:www-data:rwX') }
    it { should contain_fooacl__Conf('/var/www_user:backup:r-Xuser:www-data:rwX') }
    it { should contain_add_acl('/var/www') }
    it { should contain_add_acl('/data') }
    it { should contain_exec('/usr/local/sbin/fooacl') }
    it { should contain_elexis__acls }
  end
end

