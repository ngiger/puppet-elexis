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

describe 'elexis::users' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  let(:hiera_config) { }
  context 'when running under Debian with defaults' do
    let(:title) { 'defaults' }
    it { should contain_group('elexis').only_with(
                                                'gid'    => '1300',
                                                'ensure' => 'present',
                                                'name'   => 'elexis',
                                               ) }
    it { should contain_user('elexis').with(
    'name' => 'elexis',
    'ensure' => 'present',
    'uid'    => '1300',
    'gid'    => '1300',
    # 'password'    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
    # 'comment'    => nil,
    'shell'    => '/bin/bash',
    'group'    => nil,
  ) }
    it { should contain_user('arzt1301').with(
    'name' => 'arzt',
    'ensure' => 'present',
    'uid'    => '1301',
    'gid'    => '1301',
    'password' => nil,
    # 'password'    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
    'comment'    => 'Dr. Max Mustermann',
    'shell'    => '/bin/bash',
    'group'    => nil,
  ) }
  end
end
