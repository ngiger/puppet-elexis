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

describe 'elexis::latex' do
  let(:facts) { WheezyFacts }
  context 'when running with default parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should have_resource_count(0) }
    it { should_not contain_package('texlive') }
  end
  context 'when running under Debian with ensure' do
  let(:params) { {:ensure => true,}}
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_elexis__latex }
    it { should contain_wget }
    it { should contain_package('unzip') }
    it { should contain_package('texinfo') }
    it { should contain_package('texlive') }
    it { should contain_package('texlive-lang-german') }
    it { should contain_package('texlive-latex-extra') }
    it { should contain_file('/opt/downloads/install_floatflt.sh') }
    it { should contain_exec('/usr/share/texmf/tex/latex/misc') }
    it { should contain_exec('install_floatflt.sty').with_command('/opt/downloads/install_floatflt.sh') }
    it { should contain_wget__fetch('http://mirror.ctan.org/macros/latex/contrib/floatflt.zip') }
    
  end
end
