# == Class: elexis::windows
#
# Installs the (Med-)Elexis Version into a $samba_base/<version>
# for WINDOWS!!!
# We use OpenJDK7 under wine to run the installer (from http://jdk7.java.net/java-se-7-ri/)
class elexis::windows (
  $ensure                 = false,
  $version                = 'current',
  $install_base            = "${samba_base}/elexis-windows",
  $auto_windows_template  = 'elexis/auto_install.xml.erb'
) inherits elexis::common {

  if ($ensure == false ) {
    notice("Skipping elexis::windows as ensure is ${ensure} == false")
  } else {
  $installDir         =   "${install_base}/${version}"
  
  # just a few 80 MB
  $openjdk_url = 'http://download.java.net/openjdk/jdk7/promoted/b146/gpl/openjdk-7-b146-windows-i586-20_jun_2011.zip'
  $openjdk_download = "${install_base}/openjdk-7-b146-windows-i586-20_jun_2011.zip"

  package{['xvfb', 'wine']: }

  if !defined(Exec[$installDir]) {
    exec { $installDir:
#      command => "/bin/mkdir -p $installDir && /bin/chown elexis $installDir",
      command => "/bin/mkdir -p ${installDir}",
 #     user  => 'root',
      creates => $installDir,
      unless  => "/usr/bin/test -d ${installDir}",
      require => [ User['elexis'] ],
    }
  }
  wget::fetch { $openjdk_url:
        destination => $openjdk_download,
        timeout     => 0,
        verbose     => false,
      }
  
  $installed_java_exe = "${samba_base}/java-se-7-ri/bin/java.exe"
  elexis::unzip{'unzip_open_jdk_wine':
    zipfile => $openjdk_download,
    dest    => $installed_java_exe,
    require => [ Wget::Fetch[$openjdk_url] ],
  }

  $autoInstallXml = "${install_base}/auto_windows-${version}.xml"
  $installer      = "${install_base}/elexis-installer-${version}.jar"
#  notify{"windows $auto_windows_template via $autoInstallXml and $installer  $installDir": }
  
  file { $autoInstallXml:
    content => template($auto_windows_template),
    owner   => 'elexis',
    mode    => '0644',
    require => [ User['elexis'], Exec[ $installDir ] ],
  }

  if !defined(Package['wget']) { package{'wget': ensure => present, } }
  exec { "wget_${installer}":
    cwd     => '/tmp',
    command => "wget '${programURL}' --output-document=${installer}",
    require => [ User['elexis'],  Exec[ $installDir ], Package['wget'] ],
    path    => '/usr/bin:/bin',
    creates => $installer,
    timeout => 1800, # allow maximal 30 minutes for download
 }
  
  
  $elexis_windows_exe = "${installDir}/elexis.exe"
  notify{"Creating Windows elexis.exe at ${elexis_windows_exe}":}

  # running wine and xvfb. Example from http://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexa073.html
  # Also we need the following
  # dpkg --add-architecture i386
  # apt-get update
  # apt-get install wine-bin:i386
  
  exec { $elexis_windows_exe:
    cwd     => '/tmp',
    command => "wine ${installed_java_exe} -jar ${installer} ${autoInstallXml}",
    creates => $elexis_windows_exe,
    require => [ File[$autoInstallXml],
      Elexis::Unzip['unzip_open_jdk_wine'],
      Exec[$installDir, "wget_${installer}"],
      Package['wine', 'xvfb'], # we need an X environment for wine
      ],
    path    => '/usr/bin:/bin',
  }
  }
}