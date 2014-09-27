# == Class: elexis::demodb
#
# Downloads the demoDB into download_dir specified by elexis and
# unpacks if for a given user under $HOME/elexis/demoDB
define elexis::demodb (
  # $url         = 'http://freefr.dl.sourceforge.net/project/elexis/elexis%20full%20installation/3.0.0/demoDB_3.0_with_administrator.zip',
  $url         = 'http://download.elexis.info/demoDB/demoDB_3.0_with_administrator.zip',
  $user        = 'demo',
) {
  include elexis
  notice("elexis::demodb user ${user} and ${url} ")
  $home_elexis  =   "/home/${user}/elexis"
  $downloadFile = "${::elexis::params::download_dir}/demoDB.zip"

  ensure_resource('user', $user, { ensure => present })
  ensure_resource('file', "/home/${user}", { ensure => directory, require => User[$user], owner => $user, group => $user })
  file {$home_elexis :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0666',
    require => [ User[$user] ];
  }

  if !defined(File[$::elexis::params::download_dir]) {
    file { $::elexis::params::download_dir:
      ensure => directory,
      mode   => '0755',
    }
  }
  
  ensure_packages(['wget', 'unzip'], { ensure => present, } )
  exec { 'wget_demodb':
    command => "/usr/bin/wget '${url}' --output-document=${downloadFile}",
    require => [ File[ $::elexis::params::download_dir ], Package['wget'] ],
    creates => $downloadFile,
  }
  exec { "unzip_demodb_for_${user}":
    cwd     => $home_elexis,
    user    => $user,
    command => "/usr/bin/unzip -o -qq ${downloadFile}",
    require => [ Package['unzip'], Exec['wget_demodb'] ],
    creates => "${home_elexis}/demoDB",
  }
  
}