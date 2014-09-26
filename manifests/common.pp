# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# == Class: elexis::common
#
# implements the following operations needed in many places
#
# * ensure main user/group
# * pin puppet to a known good version
# * allows main user to sudo all stuff
#
class elexis::common() inherits elexis::params {
  $elexis_main = $::elexis::params::elexis_main
  $main_name   = $elexis_main[name]
  $main_gid    = $elexis_main[gid]
  file { $::elexis::params::download_dir:
    ensure => directory, # so make this a directory
  }
  group{$main_name:
    ensure => present,
    gid => $main_gid,
  }
  user{$main_name:
    ensure => present,
    uid    => $elexis_main[uid],
    gid    => $main_gid,
    shell  => $elexis_main[shell],
    groups => $elexis_main[groups],
  }

  if ( $::elexis::params::main_allow_sudo_all == true) {
    file {'/etc/sudoers.d/elexis':
      ensure  => present,
      content => "${main_name} ALL=NOPASSWD:ALL\n",
      mode    => '0440',
    }
  } else { file {'/etc/sudoers.d/elexis': ensure  => absent, }
  }

  if ($::elexis::params::enfore_puppet_version) {
    # notice("puppet pinned to ${::elexis::params::enfore_puppet_version}")
    apt::hold {['puppet', 'puppet-common']:
      version => '3.6*',
    }
  } else {
    notice('dangeros no enfore_puppet_version')
  }
}
