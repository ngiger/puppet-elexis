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
RSpec.configure do |c|
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'  
end

describe 'samba::server' do
  let(:facts) { WheezyFacts }

    context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
  end

  context 'when running with parameters from mustermann' do
    let(:params) {{ }}
    let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_samba__server }
    it { should contain_samba__params }
    it { should contain_package('samba') }
    it { should contain_service('samba') }
    it { should contain_file('/etc/samba/smb.conf').with_content(/Praxis Mustermann/) }
    it { should contain_file('/etc/samba/smb.conf').with_content(
      /\n\[profile\]\n\tcomment = Benutzerprofile\n\tpath = \/home\/samba\/profile\n\twritable = true\n\tbrowsable = false\n/) }
  end
end
