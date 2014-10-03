# Here we define all needed stuff to bring up a Wiki for an Elexis practice
class elexis::praxis_wiki(
  $ensure  = false,
  $vcsRoot = '/opt/src/elexis-admin.wiki',
  $gollum_name     = 'praxis_wiki'
) inherits elexis::daemontools {
  if ( $ensure == absent or $ensure == false) {
    # notice("Skipping elexis::praxis_wiki ensure ${ensure} != present")
  } else {
    # notice("elexis::praxis_wiki installing ensure is ${ensure}")
  $initFile =  '/etc/init.d/gollum'

  ensure_packages(['make', 'libxslt1-dev', 'libxml2-dev', 'libicu-dev'])
  package{  ['gollum', # markdowns is currently well supported, including live editing
    'RedCloth',  # to support textile, but no live editing at the moment
    'wikicloth'  # to support mediawiki, but no live editing at the moment
    , # needed to install gollum
    ]:
    ensure   => present,
    provider => gem,
    require  => Package['make', 'libxslt1-dev', 'libxml2-dev', 'libicu-dev'],
  }

# gollum TODO: set default to .textile, see DefaultOptions  in lib/gollum/frontend/public/javascript/editor/gollum.editor.js
# Maybe done using a config.ru file inside the wiki!
  vcsrepo {  $vcsRoot:
      ensure   => latest,
      provider => git,
      owner    => 'elexis',
      group    => 'elexis',
      source   => 'https://github.com/ngiger/elexis-admin.wiki.git',
      require  => [User['elexis'], ],
  }
  $local_bin = '/usr/local/bin'
  ensure_resource('file', $local_bin, { ensure => directory} )
  $gollum_runner = "${local_bin}/start_praxis_wiki.sh"
  $gollum_run      = "/var/lib/service/${gollum_name}/run"
  $wiki_srv_status   = running
  file{$gollum_runner:
    content => "#!/bin/bash
sudo -iHu elexis gollum ${vcsRoot} &> ${vcsRoot}/gollum.log
",
    owner   => 'elexis',
    group   => 'elexis',
    require => [User['elexis'], File[$local_bin]],
    mode    => '0755',
  }
  notice("Looking for ${elexis::params::create_service_script}")
  
  exec{ $gollum_run:
    command => "${elexis::params::create_service_script} elexis ${gollum_name} ${gollum_runner}",
    path    => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File[$elexis::params::create_service_script, $gollum_runner],
      User['elexis'],
      Package['gollum'],
    ],
    creates => $gollum_run,
    user    => 'root',
  }
  
  service{$gollum_name:
    ensure     => running,
    provider   => 'daemontools',
    path       => $::elexis::params::service_path,
    hasrestart => true,
    subscribe  => Exec[$gollum_run],
    require    => Exec[$gollum_run],
  }

  }
}
