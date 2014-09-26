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

describe 'elexis::install' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'wheezy', :lsbdistid => 'debian'}}
  context 'when running under Debian with defaults' do
    let(:title) { 'Elexis-3-OpenSource' }
#    it { should compile }
    if false # was using director. But this did not install the exe
      it { should contain_file('/opt/elexis/3.0.0').with_ensure('directory') }
      it { should contain_wget__fetch('http://mirror.switch.ch/eclipse/tools/buckminster/products/director_latest.zip') }
      it { should contain_elexis__unzip('director_exe') }
      it { should contain_exec('/usr/local/bin/director_Elexis3') }
    else
      it { should contain_wget__fetch('http://download.elexis.info/elexis.3.core/3.0.0/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip') }
      it { should contain_elexis__unzip('/opt/downloads/Elexis-3-OpenSource.zip') }
    end
    it { should contain_file('/usr/share/icons/hicolor/128x128/apps/Elexis-3-OpenSource.png') }
    it { should contain_file('/usr/share/applications/Elexis-3-OpenSource.desktop') }
    it { should contain_file('/usr/local/bin/Elexis-3-OpenSource') }
    
  end
end
