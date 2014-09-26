# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::vagrant(
  $ensure  = false,
  $vcsRoot = '/home/vagrant',
) inherits elexis::params {
  
  if ($ensure == false) {
    notice("Skip elexis::vagrant als ensure ${ensure} == false")
  } else {
    file { $vcsRoot:
      ensure => directory,
    }

    vcsrepo { "${vcsRoot}/elexis-vagrant":
        ensure   => present,
        provider => git,
        require  => [File[$vcsRoot]],
        owner    => 'vagrant',
        source   => 'git://github.com/ngiger/elexis-vagrant.git'
    }
  }
}