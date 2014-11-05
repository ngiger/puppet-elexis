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
  if ($comment == nil) { $use_comment = "$title" } else { $use_comment = "$comment" }
  if ( "$title" == "$::elexis::params::elexis_main") {
    user{ $title:
      ensure   => $ensure,
      password => $password,
      uid      => $uid,
      gid      => $uid,
      groups   => $groups,
      comment  => $use_comment,
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
      comment  => $use_comment,
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
notify{"elexis::Users ": }
  # https://tobrunet.ch/2013/01/iterate-over-datastructures-in-puppet-manifests/
class elexis::users() {
  include elexis::common
  include elexis::params
  if ($::elexis::params::ensure) {
    # notify{"Gen add_groups from  $::elexis::params::add_groups":}
    ensure_resource(group, $::elexis::params::add_groups, { ensure => present} )
    ensure_resource(group, $::elexis::params::add_system_groups, { ensure => present, system => true} )
    # notify{"Gen users from  $::elexis::params::user_definition":}
    create_resources(elexis_add_users,  $::elexis::params::user_definition, {})
  } else {
    # notify{"Skipping user generation as $::elexis::params::ensure": }
  }
}