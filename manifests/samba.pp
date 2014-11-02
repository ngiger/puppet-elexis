#== Class: elexis::samba
#
# Installs and sets up a Samba server
# TODO: Create initial password for all Samba-Users
# This one uses thias/samba, which does not check parameter
# but which allows passing everything as parameters
# which is far better for using hiera
#
class elexis::samba (
  $ensure               = absent,
  $samba_base           = '/opt/samba',
  $samba_praxis         = '/opt/samba/elexis',
  $samba_pdf            = '/opt/samba/elexis/neu',
  $pdf_ausgabe          = false,
  $with_x2go            = false,
  $x2go_win_version     = '4.0.0.3',
  $x2go_mac_version     = '4.0.1.0',
)  {
  include elexis::common
  if ($ensure != absent) {
    if ($pdf_ausgabe == false) {
      class {'samba::server': }
    } else {
  notify { 'test: elexis::samba with pdf_ausgabe': }
      $params = hiera('samba::server::shares', {})
      $share_pdf = { 'pdf-ausgabe' =>
        [
          "comment        = 'Ausgabe für Drucken in Datei via PDF'",
          'browsable      = true',
          'read_only      = true',
          "force_user     = '%S'",
          'guest_only     = false',
          'guest_ok       = true',
          'create_mask    = 0600',
          'directory_mask = 0700',
          ]
        }
      $merged_hash = merge($params, $share_pdf)
      class {'samba::server': shares => $merged_hash }

      ensure_packages(['cups-pdf', 'cups-bsd'])
      file{'/etc/cups/cups-pdf.conf':
      content => '# managed by puppet! elexis/manifests/samba.pp
Out ${HOME}/pdf
Label 0
UserUMask 0002

Grp lpadmin
LogType 3

PostProcessing /usr/local/bin/cups-pdf-renamer
',
      mode    => '0644',
      require => Package['cups-pdf'],
      }

      file{'/usr/local/bin/cups-pdf-renamer':
      content => "#!/bin/bash
# managed by puppet! elexis/manifests/samba.pp
FILENAME=`basename \$1`
# CURRENT_USER=\"\${2}\"
# CURRENT_GROUP=\"\${3}\"
DATE=`date +\"%Y-%m-%d_%H:%M:%S\"`
umask=022
sudo -u \$2 mv \$1 ${samba_pdf}/\$FILENAME && logger cups-pdf moved \$1 to ${samba_pdf}/\$FILENAME
",
      mode    => '0755',
      }
    }

    $tested_smb_conf = '/etc/samba/smb.conf.tested'
    exec{$tested_smb_conf:
      command   => "/usr/bin/testparm /etc/samba/smb.conf >${tested_smb_conf}",
      creates   => $tested_smb_conf,
      unless    => "/usr/bin/test ${tested_smb_conf} -nt /etc/smb.conf",
      # refreshonly => true,
      require   => Service['samba'],
      subscribe => Service['samba'],
    }

    file{[$samba_base, $samba_praxis, $samba_pdf]:
      ensure  => directory,
      group   => $::elexis::params::elexis_main[main],
      owner   => $::elexis::params::elexis_main[main],
#      require => User['elexis'],
      mode    => '0664',
    }

    if ($with_x2go) {
      $wget_x2go_win_client = "${samba_base}/X2GoClient_latest_mswin32-setup.exe"
      $wget_x2go_mac_client = "${samba_base}/X2GoClient_latest_macosx.dmg"
      wget::fetch{'http://code.x2go.org/releases/X2GoClient_latest_mswin32-setup.exe':
        require => [File[$samba_base]],
        timeout => 1800, # allow maximal 30 minutes for download
        destination => $wget_x2go_win_client,
      }

      wget::fetch{'http://code.x2go.org/releases/X2GoClient_latest_macosx.dmg':
        require => [File[$samba_base]],
        timeout => 1800, # allow maximal 30 minutes for download
        destination => $wget_x2go_mac_client,
      }
    }
  }
}