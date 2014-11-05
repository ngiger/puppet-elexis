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
    exec { "unzip_${dest}_${creates}":
      command => "/usr/bin/unzip -d ${dest} -o -qq ${zipfile} && /bin/chown -R $user:$group $dest",
      require => [ Package['unzip'] ],
      creates => $creates,
    }
  } else {
    exec { "unzip_${dest}":
      command => "/usr/bin/unzip -d ${dest} -o -qq ${zipfile} && /bin/chown -R $user:$group $dest",
      require => [ Package['unzip'] ],
    }
  }
}