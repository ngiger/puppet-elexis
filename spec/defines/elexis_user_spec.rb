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

describe 'elexis::user' do
  let(:facts) do
    { :osfamily => 'Debian',  :lsbdistcodename => 'wheezy'  }
  end
  context 'when running under Debian with defaults' do
    let(:title) { 'demo' }
    let(:params) { {:username => 'a_user',
                    :uid => '999',
                    :password => 'topsecret',
                    }}
    
    it { should compile }
    it { should have_resource_count(NrResourcesInElexisCommon) }
    it { should contain_elexis__user('demo') }
    it { should contain_file('Create_Home for a_user').with_path('/home/a_user').with_source( '/etc/skel').with_recurse('remote') }
    it { should contain_file('Create_Home for a_user').only_with(
                                                                 'source'  => '/etc/skel',
                                                                 'path'    => '/home/a_user', 
                                                                 'recurse' => 'remote',
                                                                 'owner'   => '999',
                                                                 'group'   => '999',
                                                                 )  
       }
  end
end
