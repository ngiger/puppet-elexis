# == Class: elexis
#
# This is a base class that can be used to modify catalog-wide settings relating
# to the various types in class contained in the elexis module.
#
# If you don't declare this class in your catalog, sensible defaults will
# be used.  However, if you choose to declare it, it needs to appear *before*
# any other types or classes from the elexis module.
#
# The parameters here are only defined for backward compatibility.
# Newer ones are defined in the elexis::params class
#
# === Examples:
#
#   class { 'elexis':
#     java               => 'openjdk-6,
#   }
#
#

class elexis (
  $db_type             = $::elexis::params::db_type,
  $db_main             = $::elexis::params::db_main,
  $db_test             = $::elexis::params::db_test,
  $db_password         = $::elexis::params::db_password,
  $db_pw_hash          = $::elexis::params::db_pw_hash,
  $java                = $::elexis::params::java,
  $binDir              = $::elexis::params::binDir,
  $service_path        = $::elexis::params::service_path,
  $jenkinsRoot         = $::elexis::params::jenkinsRoot,
  $downloadDir         = $::elexis::params::downloadDir,
  $downloadURL         = $::elexis::params::downloadURL,
  $db_type             = $::elexis::params::db_type,
) inherits elexis::params {

}
