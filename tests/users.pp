elexis::users{ "onlyElexisUser":}
if (false ) {
elexis::users{ "onlyElexisUser":
#  elexis_main     =>  { 'name2' => 'elexis', }, 
#  user_definition =>  { 'name1' =>  'demo' },
  elexis_main => {
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
  user_definition =>  { 'elexis' =>  [name        => 'demo',
    mandant     => 'true',
    ensure      => 'present', # will remove /home/arzt! (possible values absent, present, role)
    uid         => '1301',
    gid         => '1301',
    # mandanten sollen im Normalfall diversen privilegierten Gruppen angehören
    groups      => [ dialout, cdrom, elexis, plugdev, netdev, adm, sudo, ssh ],
    managehome  => true,
    # password is elexisTest
    password    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
    shell       => '/bin/bash',
    ] }    
    ,
}
elexis::users{ "onlyElexisUser":
  elexis_main => [ {
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
  } ], 
  user_definition =>  { 'elexis' =>  [name        => 'demo',
    mandant     => 'true',
    ensure      => 'present', # will remove /home/arzt! (possible values absent, present, role)
    uid         => '1301',
    gid         => '1301',
    # mandanten sollen im Normalfall diversen privilegierten Gruppen angehören
    groups      => [ dialout, cdrom, elexis, plugdev, netdev, adm, sudo, ssh ],
    managehome  => true,
    # password is elexisTest
    password    => '$6$4OQ1nIYTLfXE$xFV/8f6MIAo6XKZg8fYbF//w1lhFrCJ60JMcptwESgbHaH52c2UZbUUAAlydCRQy9wDYEgt5dUpTyHjFhCy5E',
    shell       => '/bin/bash',
    ] }    
    ,
}
}