# Allow running services via daemontools

class elexis::daemontools inherits elexis::common {
  ensure_packages(['daemontools-run'])
  file {'/var/lib/service':
    ensure => directory,
    mode   => '0644',
  }
    notice("daemontools ${::elexis::params::create_service_script} ")
  
  file { $::elexis::params::create_service_script:
    source  => 'puppet:///modules/elexis/create_service.rb',
    mode    => '0774',
    require =>         [
      File['/var/lib/service'],
      Package['daemontools-run'],
    ]
  }
}
