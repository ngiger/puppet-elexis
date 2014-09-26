# == Class: elexis::unzip
#
# Unzips a afile
# unpacks if for a given user under $HOME/elexis/demoDB
define elexis::unzip (
  $zipfile = nil,
  $dest    = nil, # a directory. If it already exists nothing will be unzipped!
  $creates = nil,
  $user    = root,
  $group   = root,
)  {
  ensure_packages(['unzip'], { ensure => present, } )
  if ($creates != nil) {
    exec { "unzip_${dest}":
      command => "/usr/bin/unzip -d ${dest} -o -qq ${zipfile}",
      require => [ Package['unzip'] ],
      creates => $creates,
      user    => $user,
      group   => $group,
    }  
  } else {
    exec { "unzip_${dest}":
      command => "/usr/bin/unzip -d ${dest} -o -qq ${zipfile}",
      require => [ Package['unzip'] ],
      user    => $user,
      group   => $group,
    }  
  }
}