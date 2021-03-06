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
  if ($ensure) {
    ensure_packages(['eclipse-rcp', 'ruby', 'mysql-workbench', 'mysql-utilities'], { ensure => present })
    if ( $elexis::params::elexis_main ) {
      $main_name   = $elexis::params::elexis_main
      ensure_resource('user', $main_name)
    }
    else { $main_name = 'root'
      ensure_resource('user', 'root')
    }
    class {"java": package => $::elexis::params::java }
    vcsrepo{$install_dir:
      ensure   => present,
      provider => git,
      source  => 'https://github.com/ngiger/bootstrap-elexis-3.git',
      require => User[$main_name],
      user    => $main_name,
      group   => $main_name,
    }
    exec{'bootstrap-elexis-3':
      require => [
        Vcsrepo[$install_dir],
        Package['eclipse-rcp', 'ruby'],
        Class['java'],
      ],
      command => "/usr/bin/ruby ${install_dir}/bootstrap_elexis_3_env.rb",
      creates => "${install_dir}/eclipse/eclipse",
    }
  }
}
