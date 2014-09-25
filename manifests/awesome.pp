# Here we define a install various utilities for the awesome


class elexis::awesome($ensure = false)
  inherits elexis::common {

  if ($ensure) {
  # we need x-display-manager, e.g. slim
  # an x-window-manager, e.g. awesome
  # demoDB is not getting installed!
    ensure_packages(['slim', 'awesome', 'xserver-xorg'], { ensure => present} )
    if !defined(Service['slim']) {
    service { 'slim':
      ensure  => running,
      require => Package['slim', 'awesome', 'xserver-xorg'],
      }
    }
  }
}
