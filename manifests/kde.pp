# Here we define a install various utilities for the kde

class elexis::kde($ensure = false,
  $display_manager = 'kdm',
)
  inherits elexis {

  if ($ensure != false and $ensure != absent) {
    ensure_packages(['task-german-kde-desktop', 'kde-plasma-desktop', 'kde-full', $display_manager], { ensure => present} )
    service{$display_manager:
      ensure => running,
      require => Package[$display_manager],
    }
  }
}
