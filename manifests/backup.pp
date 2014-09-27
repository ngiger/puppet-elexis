# == Class: elexis::backup
#
# elexis::backup backups using crontab and rsnapshot.
#
# === Parameters
#
# Document parameters here.
#
# [*backup_dir*]
#   Directory for the rsnapshots backups
#
# === Examples
#
#  class { 'elexis::backup':
#    backup_dir => '/mnt/backup',
#    backup_hourly = nil, # a daily backup is good enough for us
#    dirs_to_backup = [ '/var/www/apache' ], # backup only apache
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

class elexis::backup(
  $backup_dir           = '/opt/backup',
  $ensure               = absent,
  $backup_hourly        = '5 */4', # every 4 hours
  $backup_daily         = '15 23',
  $backup_weekly        = '30 23',
  $backup_monthly       = '45 23',
  $dirs_to_backup       = [ '/etc',
                            '/home',
                            '/opt/backup/pg/dumps',
                            '/opt/backup/mysql/dumps',
                          ],
  $pg_group             = 'postgres',
  $has_luks_backup      = false,
  $luks_keys            = nil,
) inherits elexis::params {
  if ($ensure == absent) {
    } else {
    rsnapshot::crontab{'elexis_backup':
      name         => 'elexis_backup',
      excludes     => [],
      includes     => $dirs_to_backup,
      destination  => $backup_dir,
      time_hourly  => $backup_hourly,
      time_daily   => $backup_daily,
      time_weekly  => $backup_weekly,
      time_monthly => $backup_monthly,
    }
    elexis::mkdir_p{$dirs_to_backup:}
    elexis::mkdir_p{$backup_dir:}
  }
}

