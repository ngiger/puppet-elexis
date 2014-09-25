include apt
include apt::backports
apt::source { 'wheezy':
  location    => 'http://mirror.switch.ch/ftp/mirror/debian/',
  release     => 'wheezy',
  repos       => 'main contrib non-free',
#  required_packages => 'debian-keyring',
  key         => '46925553',
  key_server  => 'subkeys.pgp.net',
  pin         => '-10',
  include_src => true
}