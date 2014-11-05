# == Class: elexis::mkdir_p
#
# elexis::backup backups using crontab and rsnapshot.
#
# === Examples
#
#  elexis::mkdir_p{['/deeply/nested/path/to/my/dir', '/or/a/short/er']:}
#
# === Authors
#
# Niklaus Giger <niklaus.giger@member.fsf.org>
#
# === Copyright
#
# Copyright 2014 Niklaus Giger
#

define elexis::mkdir_p{
  unless defined(Exec[$title]) {
    exec{"$title": command => "/bin/mkdir -p ${title}", unless => "/usr/bin/test -d ${title}" }
  }
}
