# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
# A utility class to easily add a user for Elexis
include elexis::common

# define a key value pair
# - add some stuff
define ensure_key_value($file, $key, $value, $delimiter = ' ') {
    # passing the values via the environment simplifies quoting.
    Exec {
        environment => [ "P_KEY=${key}",
                        "P_VALUE=${value}",
                        "P_DELIM=${delimiter}",
                        "P_FILE=${file}" ],
        path => '/bin:/usr/bin',
    }

    # append line if "$key" not in "$file"
    exec { "append-${name}":
        command => 'printf "%s\n" "$P_KEY$P_DELIM$P_VALUE" >> "$P_FILE"',
        unless  => 'grep -Pq -- "^\Q$P_KEY\E\s*\Q$P_DELIM\E" "$P_FILE"',
    }

    # update it if it already exists
    exec { "update-${name}":
        command => 'perl -pi -e \'s{^\Q$ENV{P_KEY}\E\s*\Q$ENV{P_DELIM}\E.*}{$ENV{P_KEY}$ENV{P_DELIM}$ENV{P_VALUE}}g\' --  "$P_FILE"',
        unless  => 'grep -Pq -- "^\Q$P_KEY\E\s*\Q$P_DELIM\E\s*\Q$P_VALUE\E$" "$P_FILE"',
    }
}

# set a password hash in /etc/shadow
# Not used at the moment. We will probably use clear text passwords
# from hiera
define setpass_hash($hash, $file='/etc/shadow') {
  ensure_key_value{ "set_pass_${name}":
    file      => $file,
    key       => $name,
    value     => "${hash}:0:0:99999:7:::",
    delimiter => ':',
    require   => User[$name],
    }
}

define setpass_cleartext($cleartext) {
  exec{"set_passwd_${title}":
    command => "/bin/echo '/usr/bin/passwd $title <<EOF' > /opt/set_passwd_${title}
/bin/echo '$cleartext'                   >> /opt/set_passwd_${title}
/bin/echo '$cleartext'                   >> /opt/set_passwd_${title}
/bin/echo 'EOF'                   >> /opt/set_passwd_${title}
/bin/bash /opt/set_passwd_${title}
",
    require   => User[$title],
    unless    => "/bin/grep ${title}:.+: /etc/shadow",
  }
}

define elexis::user(
  $username,
  $uid,
  $ensure   = present,
  $pw_clear = nil, # password as cleartext, if nil nothing will be done
  $pw_hash  = nil, # password as hash, if nil nothing will be done
) {
  if ($ensure != absent) {
    if ($pw_clear != nil)   { setpass_cleartext { $username: cleartext => $pw_clear,  } }
    elsif ($pw_hash != nil) { setpass_hash      { $username: hash      => $pw_hash,  } }
    ensure_resource('user', "$username")
    file{"Create_Home for ${username}":
      source  => '/etc/skel',
      recurse => remote,
      path    => "/home/${username}",
      owner   => $uid,
      group   => $uid,
      require => User[$username],
    }
  } else {
    file{"/home/${username}":
      ensure => absent,
      force  => true,
      recurse => true,
    }
  }
}

