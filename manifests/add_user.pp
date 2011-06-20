define elexis::add_user( $email, $uid, $ensure = present ) {

            $username = $title
  case $ensure {
    present: {
            user { $username:
                    comment => "$email",
                    home    => "/home/$username",
                    shell   => "/bin/bash",
                    uid     => $uid
            }

            group { $username:
                    gid     => $uid,
                    require => user[$username]
            }

            file { "/home/$username/":
                    ensure  => directory,
                    owner   => $username,
                    group   => $username,
                    mode    => 750,
		    source  => "/etc/skel",
		    recurse => true,
                    require => [ user[$username], group[$username] ]
            }

            file { "/home/$username/.ssh":
                    ensure  => directory,
                    owner   => $username,
                    group   => $username,
                    mode    => 700,
                    require => file["/home/$username/"]
            }

            file { "/home/$username/.bash_aliases":
                    ensure  => present,
                    owner   => $username,
                    group   => $username,
                    mode    => 644,
                    require => file["/home/$username/"],
                    content  =>
"alias ll='ls -al'
alias ls='ls --color=auto'
",
            }

            # now make sure that the ssh key authorized files is around
 #           file { "/home/$username/.ssh/authorized_keys":
 #                   ensure  => present,
 #                   owner   => $username,
 #                   group   => $username,
 #                   mode    => 600,
 #                   require => file["/home/$username/"]
 #           }
      }
    absent: {
            file { "/home/$username/":
                    ensure  => absent,
                    recurse  => true,
                    purge    => true,
                    force    => true,
            }

            user { $username:
                    uid     => $uid,
                    ensure  => absent,
            }

            group { $username:
                    gid     => $uid,
                    ensure  => absent,
            }
    }
    default: {
      fail("Invalid 'ensure' value '$ensure' for elexis::add_user")
    }
  }
}