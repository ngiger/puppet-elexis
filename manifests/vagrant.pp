# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class elexis::vagrant {
  $vcsRoot = '/home/vagrant'
    file { $vcsRoot:
      ensure => directory,
  }

#  if !defined(Package['git']) { package{ 'git': ensure => present } }
  include git

  vcsrepo { "${vcsRoot}/elexis-vagrant":
      ensure   => present,
      provider => git,
      require  => [File[$vcsRoot]],
      owner    => 'vagrant',
      source   => 'git://github.com/ngiger/elexis-vagrant.git'
  }
}