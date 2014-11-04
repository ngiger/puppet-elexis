# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# == Class: elexis::common
#
# implements the following operations needed in many places
#
# * ensure main user/group
# * pin puppet to a known good version
# * allows main user to sudo all stuff
#
class elexis::common() {
  include elexis::params
  include elexis::users
  $elexis_main   = $elexis::params::elexis_main
  notify { "commont main $elexis_main": }
  file { $::elexis::params::download_dir:
    ensure  => directory, # so make this a directory
    require => User[$elexis_main],
    owner   => $elexis_main,
    group   => $elexis_main,
  }
  if ( $::elexis::params::main_allow_sudo_all == true) {
    file {"/etc/sudoers.d/$elexis_main":
      ensure  => present,
      content => "$elexis_main ALL=NOPASSWD:ALL\n",
      mode    => '0440',
    }
  } else { file {"/etc/sudoers.d/$elexis_main": ensure  => absent, }
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
