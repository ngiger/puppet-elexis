# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# This defines the main users which "owns" the
# elexis-databases and the directories where Elexis is installed
# Should be the main mandant
#
class elexis::main_user () inherits elexis::params {
  $elexis_main     = $::elexis::params::main_user
  # notify{"Main user ist $elexis_main": }
}
