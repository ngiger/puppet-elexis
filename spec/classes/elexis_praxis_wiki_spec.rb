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

describe 'elexis::praxis_wiki' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running with default parameters' do
    it { should contain_package('gollum') }
    it { should contain_package('wikicloth') }
    it { should contain_package('RedCloth') }
    it { should contain_package('libxml2-dev') }    
  end
  context 'when running with default parameters' do
    let(:params) { {:ensure                  => 'present', }}
    it { should contain_package('gollum') }
    it { should contain_package('wikicloth') }
    it { should contain_package('RedCloth') }
    it { should contain_package('libxml2-dev') }    
    it { should contain_service('praxis_wiki') }    
    it { should contain_exec('/var/lib/service/praxis_wiki/run') }    
    it { should contain_file('/usr/local/bin/start_praxis_wiki.sh') }    
  end
end
