define elexis::install($ensure, $source, $destdir, $version) {
  $destzip = "$destdir/elexis-$version.zip"
  notify {"destzip ist $destzip":}
      exec { "elexis-$version-wget":
	creates => $destzip,
	cwd     => "$destdir",
# Diese Lösung läuft nicht, wenn die Datei auf dem Netz ändert, da zuerst alles auf stdout umgeleitet wird!
#	command => "wget -O $destzip $source",
	command => "wget $source",
	path => [ '/usr/local/bin', '/usr/bin', '/bin'],
     }
      exec { "elexis-$version-unzip":
	creates => "$destdir/elexis-$version",
	cwd     => "$destdir",
	command => "unzip -u *.zip",
	path => [ '/usr/local/bin', '/usr/bin', '/bin'],
	require => [Exec["elexis-$version-wget"]],# File[$destzip]],
#	refreshonly => true,
	notify => File["/usr/local/bin/elexis-$version"],
     }
      # create symlink in /usr/local/bin
      file {"/usr/local/bin/elexis-$version": 
	require => Exec["elexis-$version-unzip"],
	owner   => root,
	group   => root,
	mode    => 766,
	target  => "$destdir/elexis-$version/elexis",
	ensure  => link,
#	refreshonly => true,
     }
      file { "$destdir/elexis-$version/elexis":
	mode => 0777,
	ensure => present,
	require =>[Exec["elexis-$version-unzip"], 
		   File["/usr/local/bin/elexis-$version"],
#		   Package["sun-java6-jdk"]
		], 

 }
}
