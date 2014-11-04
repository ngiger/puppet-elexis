# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
#
# Add all elexis users
# as defined from $::elexis::params::user_definition

define elexis_add_users(
  $mandant = true,
  $ensure  = true,
  $uid     = 7777, # $gid will always be set to $uid
  $groups  = [],
  $comment = nil,
  $managehome = false,
  $shell      = '/bin/bash',
  $pw_clear   = nil,
  $pw_hash    = nil,
) {
  group{$title: gid => $uid, ensure => present}
  if ( "$title" == "$::elexis::params::elexis_main") {
    user{ $title:
      ensure   => $ensure,
      password => $password,
      uid      => $uid,
      gid      => $uid,
      groups   => $groups,
      comment  => $comment,
      shell    => $shell,
      require  => Group[$groups],
    }
  } else {
    user{ $title:
      ensure   => $ensure,
      password => $password,
      uid      => $uid,
      gid      => $uid,
      groups   => $groups,
      comment  => $comment,
      shell    => $shell,
      require  => [
        Group[$groups],
        User[$::elexis::params::elexis_main], # elexis_main must be created first!
      ]
    }
  }
  elexis::user{$title:
    username  => $title,
    uid       => $uid,
    ensure    => $ensure,
    pw_clear  => $pw_clear,
    pw_hash   => $pw_hash
  }
}
  # https://tobrunet.ch/2013/01/iterate-over-datastructures-in-puppet-manifests/
class elexis::users() {
  include elexis::common
  include elexis::params
  # notify{"Gen users from  $::elexis::params::user_definition":}
  create_resources(elexis_add_users,  $::elexis::params::user_definition, {})
  ensure_resource(group, $::elexis::params::add_groups)
}