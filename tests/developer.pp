class{'elexis::bootstrap': ensure => present}
class{'elexis::awesome': ensure => present}
class{'elexis::kde': ensure => present}
elexis::install  {'Elexis-3-OpenSource':}
elexis::demodb {'demoDB for elexis': user => 'elexis' }
ensure_packages (['eclipse-rcp', 'mysql-workbench', 'mysql-utilities', 'pgadmin3',])
