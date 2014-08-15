include elexis::common
if (false)  { # haraldsk/nfs needs also in puppet.conf
  # storeconfigs = true
  # dbadapter = sqlite3
  # leads to (Exec[concat_/etc/exports] => Concat[/etc/exports] => Service[nfs-kernel-server] => Class[Nfs::Server::Debian] => Concat[/etc/exports] => Exec[concat_/etc/exports])

    class { 'nfs::server':
      nfs_v4 => true,
      nfs_v4_export_root_clients =>
        '172.25.1.0/24(rw,fsid=root,insecure,no_subtree_check,async,no_root_squash)'
    }
    nfs::server::export{ '/opt/x2gothinclient.schoebu/chroot':
      ensure  => 'mounted',
      clients => '172.25.1.0/24(rw,insecure,no_subtree_check,async,no_root_squash) localhost(rw)'
  }
# nfs::export { '/export/sysadmins': }
 class { 'nfs::server':
    package => latest,
    service => running,
    enable  => true,
}
nfs::export { '/etc':
    options => [ 'rw', 'async', 'no_subtree_check' ],
    clients => [ "172.25.1.0/24" ],
}
} else { # arusso/nfs'
#  include nfs
}
