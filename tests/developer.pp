notice('bootstrapping elexis 3 developement with mysql, mysql-workbench and postgresql')
class{"elexis::bootstrap": ensure => present}
class{"elexis::awesome": ensure => present}
class{"elexis::kde": ensure => present}
ensure_packages(['eclipse-rcp', 'mysql-workbench', 'mysql-utilities', 'pgadmin3',])
