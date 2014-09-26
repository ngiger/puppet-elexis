# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
#
# A utility class to easily add users for Elexis
# The definitions are found under elexis::params
#
class elexis::users() inherits elexis::common { 
  elexis_add_users{$::elexis::params::user_definition: }
}

define elexis_add_users(
) {
  include elexis::common
  $username = $title['name']
  $expire_log = "/var/log/expire_user_${username}"
  $comment    = $title['comment']
  $ensure   = $title['ensure']
  $groups   = $title['groups']
  $shell    = $title['shell']
  $uid      = $title['uid']
  $gid      = $title['gid']
  
  # comment Motzt bei nicht US-ASCII Kommentaren wir Müller, aber nur wenn
  # der kommentar schon definiert wurde
  if ($username != undef) {
    elexis::user{$username:
      username => $username,
      password => $title['password'],
      uid      => $uid,
      gid      => $gid,
      groups   => $groups,
      comment  => $comment,
      shell    => $shell,
      ensure   => $ensure,
      require  => User[$::elexis::params::main_user], # elexis must be created first!
    }
  }
}
