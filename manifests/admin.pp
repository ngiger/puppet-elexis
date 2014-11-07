# Here we define a install various utilities for the administrator

class elexis::admin (
  $ensure     = $::elexis::params::ensure,
  $pg_util_rb = '/usr/local/bin/pg_util.rb',
  $packages   = [fish, mosh, screen, lm-sensors, git, unzip, dlocate, mlocate, htop, curl, bzr, unattended-upgrades, anacron],
  $editor_package = "",
) inherits elexis::params {
  $managed_note = hiera('managed_note', '# managed by puppet elexis::admin')
  # always ensure correct permission. Else the ssh-server would not work
  file { '/etc/ssh':
    ensure => directory,
    mode   => '0600',
    recurse => true,
  }
  if ($ensure) {
    ensure_packages($packages)
    # this ensure
    if ($vagrant == 1) {
      if false {
      file{'/etc/hiera.yaml':
        ensure => file,
        source => "${::settings::confdir}/hiera.yaml",
      }
      file{'/etc/hiera.yaml1':
        ensure => file,
        # source => "${::settings::confdir}/hiera.yaml",
        content => "# default configuration written by $managed_note with default values for demo of elexis-vagrant
# http://www.glennposton.com/posts/puppet_best_practices__environment_specific_configs
---
:backends:
  - yaml
:yaml:
  :datadir: '${settings::confdir}/hiera-example-practice'
:hierarchy:
  - '%{::environment}/%{::fqdn}'
  - '%{::environment}/%{::hostname}'
  - '%{::environment}/%{calling_module}'
  - '%{::environment}/%{::environment}'
  - 'common/%{calling_module}'
  - common
",
      }
      file_line { 'datadir_/etc/hiera.yaml':
        ensure => present,
        path   => '/etc/hiera.yaml.2',
        line   => "  :datadir: '${settings::confdir}/hiera-example-practice'",
        match  => "\s+:datadir:\s+",
      }
      }
    }

    # The config writer personal choice
    if $editor_package {
      ensure_packages([ $editor_package ])
      $editor_path = regsubst("/usr/bin/$editor_package", '-', '.')
      exec {'set_default_editor':
        command     => "update-alternatives --set editor ${editor_path}",
        # require => Package[$editor_package],
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        environment => 'LANG=C',
        unless      => "update-alternatives --display editor --quiet | grep currently | grep ${$editor_path}"
      }
    }

    exec {'set_timezone_zurich':
      command     => "echo 'Europe/Zurich' > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata",
      path        => '/usr/bin:/usr/sbin:/bin:/sbin',
      environment => 'LANG=C',
      unless      => 'grep Europe/Zurich /etc/timezone'
    }

    # needed to install via elexis-cockpit
    $installBase = 'dummy'
    file {'/etc/auto_install_elexis.xml':
      content => template('elexis/auto_install.xml.erb'),
      mode    => '0644',
    }
    # --- done patching module apt

    file {'/etc/apt/apt.conf.d/50unattended-upgrades':
      content => template('elexis/unattended_upgrades.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }

    file {$pg_util_rb:
      ensure  => present,
      mode    => '0755',
      content => template('elexis/pg_util.rb.erb'),
    }

    # permissions for these commands
    file { '/usr/local/bin/reboot.sh':
      content => "sudo /sbin/shutdown -r -t 30 1\n",
      owner   => root,
      group   => root,
      mode    => '6554',
    }

    file { '/usr/local/bin/halt.sh':
      content => "sudo /sbin/shutdown -h -t 30 1\n",
      owner   => root,
      group   => root,
      mode    => '6554',
    }
  } else {
    file {$pg_util_rb: ensure  => absent, }
  }
}
