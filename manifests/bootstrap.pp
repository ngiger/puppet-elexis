# Here we define a install various utilities to bootstrap
# an elexis 3 bootstrap development environment

include git
include elexis::mysql_server
include elexis::postgresql_server
# === Examples:
#
#   class { 'elexis::bootstrap':
#     ensure => true,
#   }
#

class elexis::bootstrap(
  $ensure = false,
  $install_dir = '/opt/bootstrap-elexis-3',
) inherits elexis::common {
  if ($ensure !=  absent and $ensure != false) {
    ensure_packages(['eclipse-rcp', 'ruby', 'mysql-workbench', 'mysql-utilities', 'openjdk-7-jdk'], { ensure => present })
    vcsrepo{$install_dir:
      ensure   => present,
      provider => git,
      source   => 'https://github.com/ngiger/bootstrap-elexis-3.git'
    }
    exec{'bootstrap-elexis-3':
      require => [
        Vcsrepo[$install_dir],
        Package['eclipse-rcp', 'openjdk-7-jdk', 'ruby'],
      ],
      command => "/usr/bin/ruby ${install_dir}/bootstrap_elexis_3_env.rb",
      creates => "${install_dir}/eclipse/eclipse",
    }
  }
}
