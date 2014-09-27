#== Class: elexis::samba
#
  define elexis_samba_options($option_definition = undef) {
    if ($server_options) {
      add_samba_option{"add_samba_option ${option_definition}":}
    }
  }
  
  define add_samba_option() {
    $option_name = $title['name']
    set_samba_option{$option_name:
      value => $title['value'],
      name  => $option_name,
    }
  }

  define elexis_samba_shares($share_definition) {
    if ($share_definition) {
      add_samba_share{$share_definition:}
    }
  }

  define add_samba_share() {
    $share_name = $title['name']
    $path       = $title['path']
    samba::server::share{$share_name:
      browsable            => $title['browsable'],
      comment              => $title['comment'],
      create_mask          => $title['create_mask'],
      directory_mask       => $title['directory_mask'],
      # don't pass not force_parameters which only produce errrors with samba 3
      guest_ok             => $title['guest_ok'],
      guest_only           => $title['guest_only'],
      path                 => $path,
      public               => $title['public'],
      write_list           => $title['write_list'],
      printable            => $title['printable'],
      valid_users          => $title['valid_users'],
      force_user           => $title['force_user'],
      force_group          => $title['force_group'],
      require              => Package['samba'],
      notify               => Exec[$elexis::samba::tested_smb_conf],
    }
    if ($path) { exec{$path:
        command => "/bin/mkdir -p ${path}",
        unless  => "/usr/bin/test -d ${path}",
      }
    }
  }

# Installs and sets up a Samba server
# TODO: Create initial password for all Samba-Users
class elexis::samba (
  $ensure               = absent,
  $samba_base           = '/opt/samba',
  $samba_praxis         = '/opt/samba/elexis',
  $samba_pdf            = '/opt/samba/elexis/neu',
) inherits elexis::common {
  if ($ensure != absent) {
  include samba
  include samba::server::config
  $augeas_packages = "['augeas-lenses', 'augeas-tools', 'libaugeas-ruby']"
  $with_x2go        = hiera('x2go::ensure', false)
  ensure_packages(['augeas-lenses', 'augeas-tools', 'libaugeas-ruby', 'cups-pdf', 'cups-bsd'])

  class {'samba::server':
    server_string        => 'Samba Server for an Elexis practice',
    interfaces           => 'eth0 lo',
    security             => 'share',
    unix_password_sync   => true,
    workgroup            => 'Elexis-Praxis',
    bind_interfaces_only => true,
    require              => [ Package['augeas-lenses', 'augeas-tools', 'libaugeas-ruby'], ],
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

  file{[$samba_base, $samba_praxis,  $samba_pdf]:
    ensure  => directory,
    group   => 'elexis',
    owner   => 'elexis',
    require => User['elexis'],
    mode    => '0664',
  }
  
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
  
  $share_definition = hiera('samba::server::shares', undef)
  if ($share_definition) {
    elexis_samba_shares{'elexis_shares':  share_definition => $share_definition}
  }
  }
  if (hiera('samba::server::pdf-ausgabe', false)) {
    samba::server::share {'pdf-ausgabe':
      comment        => 'Ausgabe für Drucken in Datei via PDF',
      path           => $samba_pdf,
      browsable      => true,
      read_only      => true,
      force_user     => '%S',
      guest_only     => false,
      guest_ok       => false,
      create_mask    => 0600,
      directory_mask => 0700,
    }
  }
  
  $server_options =  hiera('samba::server::options', 'dummy')
  if ($server_options) {
    elexis_samba_options{'elexis_samba_options': option_definition => $server_options}
  }

  if ($with_x2go) {
    ensure_packages(['wget'])
    $win_version = '4.0.0.3'
    $mac_version = '4.0.1.0'
    $wget_x2go_win_client = "${samba_base}/X2GoClient_latest_mswin32-setup.exe"
    $wget_x2go_mac_client = "${samba_base}/X2GoClient_latest_macosx.dmg"
    
    exec { $wget_x2go_mac_client:
      cwd     => $samba_base,
      command => 'wget --timestamping http://code.x2go.org/releases/X2GoClient_latest_mswin32-setup.exe',
      require => [File[$samba_base], Package['wget'] ],
      path    => '/usr/bin:/bin',
      timeout => 1800, # allow maximal 30 minutes for download
      creates => $wget_x2go_mac_client,
    }
    
    exec { $wget_x2go_win_client:
      cwd     => $samba_base,
      command => 'wget --timestamping http://code.x2go.org/releases/X2GoClient_latest_macosx.dmg',
      require => [File[$samba_base], Package['wget'] ],
      path    => '/usr/bin:/bin',
      timeout => 1800, # allow maximal 30 minutes for download
      creates => $wget_x2go_mac_client,
    }
  }
}