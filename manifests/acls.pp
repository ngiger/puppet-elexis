# == Class: elexis::backup
#
# elexis::acls allow definitions of ACL via a hieradata
#
# === Parameters
#
# Document parameters here.
#
# [*conf*]
#   The acls to configure
#
# === Examples
#
#  class { 'elexis::acls':
#    conf =>  { '/var/www' => { 'permissions' => ['user:backup:r-X', 'user:www-data:rwX' ] } },
#  }
#
# === Authors
#
# Niklaus Giger <niklaus.giger@member.fsf.org>
#
# === Copyright
#
# Copyright 2014 Niklaus Giger
#

class elexis::acls(
  $conf                 = {},
)  {
  if ($ensure == absent) {
    } else {
    # https://tobrunet.ch/2013/01/iterate-over-datastructures-in-puppet-manifests/
    create_resources(add_acl, $conf, {})  # no default values
  }
}

define add_acl($permissions) {
  fooacl::conf {"${title}_${permissions}":  target => $title, permissions => $permissions ,  }
}
