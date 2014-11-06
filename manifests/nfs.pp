# Here we define a install various utilities for the administrator

class elexis::nfs (
  $client     = false,
  $mounts     = {},
  $server     = false,
) {
  # notify{"elexis::nfs client $client server $server": }
  if $client {
    include nfs::client
    create_resources('one_nfs_mount',  $mounts, {})
  }
  if $server {
    include nfs::server
    include nfs::exports
  }
}

define one_nfs_mount(
  $device   = nil,
  $fstype   = 'nfs',
  $ensure   = 'mounted',
  $options  = 'defaults',
  $atboot   = true,
) {
  elexis::mkdir_p{$title:}
  mount{"$title":
        device  => "$device",
        fstype  => "$fstype",
        ensure  => "$ensure",
        options => "$options",
        atboot  => $atboot,
  }
}
