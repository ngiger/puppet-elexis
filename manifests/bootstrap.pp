# Here we define a install various utilities to bootstrap
# an elexis 3 bootstrap development environment


class elexis::bootstrap(
  $ensure = false, 
  $install_dir = '/opt/bootstrap-elexis-3',)
inherits elexis {
  if ($ensure !=  absent and $ensure != false) {
    include  elexis::mysql_server
    include  elexis::postgresql_server
    include git
    ensure_packages(['eclipse-rcp', 'ruby', 'mysql-workbench', 'mysql-utilities', 'openjdk-7-jdk'], { ensure => present })
    git::repo{'bootstrap-elexis-3':
      path   => $install_dir,
      source => 'https://github.com/ngiger/bootstrap-elexis-3.git'
    }
    exec{'bootstrap-elexis-3':
      require => [
        Git::Repo['bootstrap-elexis-3'],
        Package['eclipse-rcp', 'openjdk-7-jdk', 'ruby'],
      ],
      command => "/usr/bin/ruby ${install_dir}/bootstrap_elexis_3_env.rb",
      creates => "${install_dir}/eclipse/eclipse",
    }
  }
}
