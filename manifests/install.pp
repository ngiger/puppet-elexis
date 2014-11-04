# == Class: elexis::install
#
# Installs the Elexis OpenSource Version into a $install_base/<version>
# you can have more than one installation in parallel
# A shortcut for the $title is placed under /usr/local/bin
#

define elexis::install (
  $exe_name               = 'Elexis3',
  $version                = '3.0.0',
  $install_base           = '/opt/elexis',
  $full_zip_url           = 'http://download.elexis.info/elexis.3.core/3.0.0/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip',
  $features_2_install     = { 'http://download.elexis.info/elexis.3.core/release' => [
# /opt/bootstrap-elexis-3/director/director -list -r http://download.elexis.info/elexis.3.core/release | grep feature.group | cut -d = -f1 | sort | uniq |
                              'ch.elexis.core.application.feature.feature.group',
                              'ch.elexis.core.common.feature.feature.group',
                              'ch.elexis.core.logging.feature.feature.group',
                              'ch.elexis.core.ui.feature.feature.group',
                              'ch.elexis.core.ui.p2.feature.feature.group', ],
                              'http://download.elexis.info/elexis.3.base/release' => [
# /opt/bootstrap-elexis-3/director/director -list -r http://download.elexis.info/elexis.3.base/release |grep feature.group| cut -d = -f1 | sort | uniq | grep -v source
  'at.medevit.elexis.decision.feature.feature.group',
  'at.medevit.elexis.loinc.feature.feature.group',
  'at.medevit.elexis.medietikette.feature.feature.group',
  'ch.docbox.elexis.feature.feature.group',
  'ch.elexis.agenda.feature.feature.group',
  'ch.elexis.archie.patientstatistik.feature.feature.group',
  'ch.elexis.archie.wzw.feature.feature.group',
  'ch.elexis.base.befunde.feature.feature.group',
  'ch.elexis.base.ch.feature.feature.group',
#  'ch.elexis.base.ch.legacy.feature.feature.group',
  'ch.elexis.base.konsextension.bildanzeige.feature.feature.group',
  'ch.elexis.base.konsextension.privatnotizen.feature.feature.group',
  'ch.elexis.base.messages.feature.feature.group',
#  'ch.elexis.base.textplugin.feature.feature.group',
  'ch.elexis.buchhaltung.basis.feature.feature.group',
#  'ch.elexis.connect.afinion.feature.feature.group',
#  'ch.elexis.connect.mythic.feature.feature.group',
#  'ch.elexis.connect.reflotron.v2.feature.feature.group',
#  'ch.elexis.connect.sysmex.feature.feature.group',
  'ch.elexis.externe_dokumente.feature.feature.group',
  'ch.elexis.fop_wrapper.feature.feature.group',
  'ch.elexis.global_inbox.feature.feature.group',
  'ch.elexis.icpc.feature.feature.group',
  'ch.elexis.icpc.fire.feature.feature.group',
#  'ch.elexis.laborimport.analytica.feature.feature.group',
#  'ch.elexis.laborimport.bioanalytica.feature.feature.group',
#  'ch.elexis.laborimport.hl7.allg.feature.feature.group',
#  'ch.elexis.laborimport_labtop.feature.feature.group',
#  'ch.elexis.laborimport_lg1.feature.feature.group',
#  'ch.elexis.laborimport.medics.v2.feature.feature.group',
#  'ch.elexis.laborimport_rischbern.feature.feature.group',
#  'ch.elexis.laborimport_rothen.feature.feature.group',
#  'ch.elexis.laborimport.teamw.feature.feature.group',
#  'ch.elexis.laborimport_viollier.feature.feature.group',
#  'ch.elexis.laborimport.viollier.v2.feature.feature.group',
  'ch.elexis.molemax.feature.feature.group',
  'ch.elexis.notes.feature.feature.group',
  'ch.elexis.omnivore.feature.feature.group',
  'ch.elexis.privatrechnung.feature.feature.group',
  'ch.elexis.stickynotes.feature.feature.group',
#  'ch.elexis.support.dbshaker.feature.feature.group',
  'ch.medelexis.text.templator.feature.feature.group',
  'ch.medshare.connect.abacusjunior.feature.feature.group',
  'ch.medshare.elexis_directories.feature.feature.group',
  'ch.medshare.mediport.feature.feature.group',
  'ch.unibe.iam.scg.archie.feature.feature.group',
  'ch.weirich.templator.pages.feature.feature.group',
  'com.hilotec.elexis.kgview.feature.feature.group',
  'com.hilotec.elexis.messwerte.v2.feature.feature.group',
  'com.hilotec.elexis.opendocument.feature.feature.group',
  'com.hilotec.elexis.pluginstatistiken.feature.feature.group',
  'de.fhdo.elexis.perspective.feature.feature.group',
  'net.medshare.connector.aerztekasse.feature.feature.group',
  'org.iatrix.bestellung.rose.feature.feature.group',
  'org.iatrix.feature.feature.group',
  'org.iatrix.messwerte.feature.feature.group',
  'waelti.statistics.feature.feature.group',
                            ], }
) {
  include ::wget
  include ::elexis::users
  $main_user      = $::elexis::params::elexis_main
  $install_dir    = "${install_base}/${version}"
  $full_exec_path = "${install_dir}/${exe_name}"
  $director_url   = 'http://mirror.switch.ch/eclipse/tools/buckminster/products/director_latest.zip'
  $director_zip   = "${::elexis::params::download_dir}/director_latest.zip"
  $director_exe   = '/usr/local/bin/director/director'
  $elexis_zip     = "${::elexis::params::download_dir}/${title}.zip"

  file { $install_base:
    ensure  => directory,
    owner   => $main_user,
    group   => $main_user,
    mode    => '0755',
    require => [ User[$main_user] ];
  }

  ensure_resource('file', $install_dir, {
    ensure  => directory,
    owner   => $main_user,
    group   => $main_user,
    mode    => '0755',
    require => File[ $install_base ],
  } )

  if (false) {  # tried using the director, but it did not install a full elexis
    $install_helper = "/usr/local/bin/director_${exe_name}"
    wget::fetch { $director_url:
          destination => $director_zip,
          timeout     => 0,
          verbose     => false,
        }

    file {$install_helper:
      content =>  template('elexis/director_install.rb.erb'),
      mode    => '0755',
    }

  #  exit 1 unless system #{INSTALL_CMD} -repository #{REPOS.keys.join(' -r ')} -installIUs #{REPOS.values.join(' -i ')} })
    elexis::unzip{'director_exe':
      zipfile => $director_zip,
      dest    => '/usr/local/bin',
      require => Wget::Fetch[$director_url],
      creates => '/usr/local/bin/director',
    }

    exec {$install_helper:
      creates => $full_exec_path,
      require => [ File[$install_helper],
        Elexis::Unzip['director_exe'],
        ]
    }

    $precondition_for_elexis = Exec[$install_helper]

  } else { # use full zip

    wget::fetch { $full_zip_url:
          destination => $elexis_zip,
          timeout     => 0,
          verbose     => false,
        }


    elexis::unzip{$elexis_zip:
      zipfile => $elexis_zip,
      dest    => $install_dir,
      require => Wget::Fetch[$full_zip_url],
      creates => $full_exec_path,
      user    => $main_user,
      group   => $main_user,
    }
    $precondition_for_elexis = Elexis::Unzip[$elexis_zip]
  }

  # elexis always wants to open a pdf with evince and not okular
  # Debian sets evince as default pdf-viewer in /etc/mailcap or ~/.mailcap
  # is this true? September 2014 found okular in /etc/mailcap in server-VM
  ensure_packages(['evince', 'iceweasel'], { ensure => present, } )

  $logicalLink = "/usr/local/bin/${title}"
  file { $logicalLink:
    ensure  => link,
    target  => $full_exec_path,
    mode    => '0755',
    require => $precondition_for_elexis,
  }

  file { "/usr/share/applications/${title}.desktop":
      ensure  => present,
      content => "[Desktop Entry]
Name=Elexis for medical practices
Name[de]=Elexis für die Praxis (${title})
Type=Application
Exec=${title}
Icon=${title}
Categories=Office;MedicalSoftware;Science;Java
",
      mode    => '0644',
      require => [ File[$logicalLink],],
    }

    file { "/usr/share/icons/hicolor/128x128/apps/${title}.png":
      source  => 'puppet:///modules/elexis/elexis.png', # copied from ch.ngiger.opensource/splash.png
      mode    => '0644',
      require => File[$logicalLink],
    }
}
# Desktop Entry]
# Name=MySQL Workbench
# Comment=MySQL Database Design, Administration and Development Tool
# Exec=/usr/lib/mysql-workbench/bin/mysql-workbench
# Terminal=false
# Type=Application
# Icon=mysql-workbench
# MimeType=application/vnd.mysql-workbench-model;
# Categories=GTK;Database;Development;

