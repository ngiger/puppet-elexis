class { 'elexis':
  jenkins_root => '/srv/jenkins'
}

include elexis::jenkins_slave

