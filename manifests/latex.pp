# Here we define all the LaTeX packages, which we need to create Elexis documentation

class elexis::latex (
  $ensure   = false,
  $dest_dir = '/usr/share/texmf/tex/latex/misc',
  $dest_zip = '/var/cache/floatflt.zip',
  $floatflt_url = 'http://mirror.ctan.org/macros/latex/contrib/floatflt.zip',
) inherits elexis::params {
  $float_sty_name = "$dest_dir/floatflt.sty"
  if ($ensure != false) {
  if !defined(Package['unzip']) { package {'unzip': ensure => present, } }
  package {['texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']:
    ensure => present,
  }

  wget::fetch{"${floatflt_url}": destination => $dest_zip}

  exec { $dest_dir:
    command => "mkdir -p ${dest_dir}",
    path    => '/usr/bin:/bin',
    creates => $dest_dir
  }

  $cmd_file = "${::elexis::params::download_dir}/install_floatflt.sh"
  file {$cmd_file:
    mode    => '0755',
    content => "#!/bin/bash -v
cd ${::elexis::params::download_dir}
# Just in case we got called a second time
rm -rf floatflt
unzip ${dest_zip}
cd floatflt
latex floatflt.ins
cp floatflt.sty ${float_sty_name} && texhash
",
  }


  exec {'install_floatflt.sty':
    command => $cmd_file,
    creates => $float_sty_name,
    cwd     => $::elexis::params::download_dir,
    path    => '/usr/bin:/bin',
    require => [File[$cmd_file],
    Exec[$dest_dir],
    Wget::Fetch[$floatflt_url],
    Package['unzip', 'texlive', 'texinfo', 'texlive-lang-german', 'texlive-latex-extra']],
  }
}
}
