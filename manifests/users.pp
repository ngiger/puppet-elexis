# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# A utility class to easily add users for Elexis
define elexis::users(
  $elexis_main = {
  name        => 'elexis',
  mandant     => true,
  ensure      => present,
  uid         => '1300',
  gid         => '1300',
  group       => 'elexis',
  groups      => [ dialout, cdrom, plugdev, netdev, adm, sudo, ssh ],
  comment     => 'Elexis User for Database and backup',
  managehome  => true,
  password    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
  shell       => '/bin/bash',
  } , 
  $user_definition =  [ { name        => 'arzt',
    mandant     => 'true',
    ensure      => 'present', # will remove /home/arzt! (possible values absent, present, role)
    uid         => '1301',
    gid         => '1301',
    comment     => 'Dr. Max Mustermann',
    # mandanten sollen im Normalfall diversen privilegierten Gruppen angehören
    groups      => [ dialout, cdrom, elexis, plugdev, netdev, adm, sudo, ssh ],
    managehome  => true,
    # password is elexisTest
    password    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
    shell       => '/bin/bash',
   } ]
    ,
) { 
  elexis_add_users{$user_definition: }
  ensure_resource( 'group', $elexis_main['name'], {ensure => present, gid => $elexis_main[gid] })
  ensure_resource( 'user', $elexis_main['name'], 
                   { ensure => present, 
                     uid => $elexis_main[uid],
                     gid => $elexis_main[gid],
                     groups => $elexis_main[groups],
                     managehome => $elexis_main[managehome],
                     password => $elexis_main[password],
                     shell => $elexis_main[shell],                     
                  } )
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
