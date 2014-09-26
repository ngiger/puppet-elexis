# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# This defines the main users which "owns" the
# elexis-databases and the directories where Elexis is installed
# Should be the main mandant
#
class elexis::main_user () inherits elexis::params {
  $elexis_main     = $::elexis::params::elexis_main
  ensure_resource( 'group', $elexis_main['name'], {ensure => present, gid => $elexis_main[gid] })
  ensure_resource( 'user', $elexis_main['name'],
                   { ensure => present,
                     uid => $elexis_main[uid],
                     gid => $elexis_main[gid],
                     groups => $elexis_main[groups],
                     # managehome => $elexis_main[managehome],
                     # password => $elexis_main[password],
                     shell => $elexis_main[shell],
                  } )
}
