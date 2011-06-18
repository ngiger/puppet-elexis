# Add contrib and non-free component for our preferred mirror

# to test start with things like
# augtool print '/files/etc/hosts/*/*[../ipaddr = "127.0.0.1"]'
# augtool print '/files/etc/apt/sources.list/*[type = "deb-src"]'
# augtool print "/files/etc/apt/sources.list/*[uri = 'http://ftp.ch.debian.org/debian/' and type = 'dummy']"
# fuer etc/group             onlyif => "match ${group}/*[../user='${real_user}'] size == 0"
 #   onlyif  => "match service-name[.='sshjump-$name'][port='$local_port'][protocol='tcp'] size == 0";

define elexis::non-free($ensure, $type, $uri, $distribution = $lsbdistcodename, $component1, $component2 , $component3) {
  augeas{"sources.list.$uri.$type":
    context => "/files/etc/apt/sources.list",
    changes => [
       "set \"*[uri = '$uri' and type = '$type']/type\" $type",
       "set \"*[uri = '$uri' and type = '$type']/uri\"  $uri",
       "set \"*[uri = '$uri' and type = '$type']/distribution\" $distribution",
       "set \"*[uri = '$uri' and type = '$type']/component[1]\" $component1",
       "set \"*[uri = '$uri' and type = '$type']/component[2]\" $component2",
       "set \"*[uri = '$uri' and type = '$type']/component[3]\" $component3",
    ], 
    onlyif => "match *[uri = '$uri' and type = '$type'] size > 0",
  }

#  augeas{"sources.list.$uri.$type.add":
#    context => "/files/etc/apt/sources.list",
#    fail{"Cannot (yet?) add a line to sources.list"},
#    changes => [
#       "ins myLabel after \"*[last()]\"",
#       "set \"*[last()]/type\" $type",
#       "set \"*[last()]/type\" $type",
#       "set \"*[last()]/uri\"  $uri",
#       "set \"*[last()]/distribution\" $distribution",
#       "set \"*[last()]/component[1]\" $component1",
#       "set \"*[last()]/component[2]\" $component2",
#       "set \"*[last()]/component[3]\" $component3",
#    ], 
#    onlyif => "match *[uri = '$uri' and type = '$type'] size == 0",
#
#  }

      #"ins type uri component main",
      #"set \"typ niklaus",
      #"set uri  mirror",
      #"set component non-freex",
        #"set \"*[last()]/type\" $type",
#        "set \"*[last()]/uri\" $uri",
#        "set \"*[last()]/component[1]\" $component1",
#        "set \"*[last()]/component[2]\" $component2",
#        "set \"*[last()]/component[3]\" $component3",
#        "set \"*[last()]/distribution\" $lsbdistcodename",
#    "ins uri after uri[last()]",
# was okay    "set \"1/type\" \"deb-ng\"",
#	 "set \"/type[. = 'deb']\" \"deb-ngx\"",
#    "set \'*[uri = 'my_mirror_path']/uri' my_mirror_path",
#    "set \'*[uri = 'my_mirror_path']/distribution' squeeze",
}

