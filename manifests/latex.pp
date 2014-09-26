# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::latex (
  $ensure   = false,
  $destDir  = '/usr/share/texmf/tex/latex/misc',
  $floatStyName = "${destDir}/floatflt.sty",
  $floatfltURL = 'http://mirror.ctan.org/macros/latex/contrib/floatflt.zip',
) inherits elexis::params {
  if ($ensure != false) {
  if !defined(Package['unzip']) { package {'unzip': ensure => present, } }
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

  $cmd = "wget --timestamp -O ${dest_zip} ${floatfltURL}"
  exec {"X${dest_zip}":
    command => $cmd,
    creates => $dest_zip,
    cwd     => $elexis::download_dir,
    path    => '/usr/bin:/bin',
    require => File[$elexis::download_dir],
  }

  exec { $destDir:
    command => "mkdir -p ${destDir}",
    path    => '/usr/bin:/bin',
    creates => $destDir
  }

  $cmdFile = "/${elexis::download_dir}/install_floatflt.sh"
  file {$cmdFile:
    mode    => '0755',
    content => "#!/bin/bash -v
cd ${elexis::download_dir}
# Just in case we got called a second time
rm -rf floatflt
unzip ${dest_zip}
cd floatflt
latex floatflt.ins
cp floatflt.sty ${floatStyName} && texhash
",
  }


  exec {$floatStyName:
    command => $cmdFile,
    creates => $floatStyName,
    cwd     => $elexis::download_dir,
    path    => '/usr/bin:/bin',
    require => [File[$cmdFile],
    Exec[$destDir, "X${dest_zip}"],
    Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']],
  }
}
}
