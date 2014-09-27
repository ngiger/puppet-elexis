# include most of the elexis modules
class {'elexis::admin': ensure => true}
class {'elexis::app':}
class {'elexis::awesome': ensure => true}
class {'elexis::bootstrap': ensure => true}
class {'elexis::client': }
# class {'elexis::jenkins_commons': ensure => true}
# class {'elexis::jenkins_slave': ensure => true}
class {'elexis::latex': ensure => true}
# class {'elexis::mail': ensure => true}
class {'elexis::mysql_server': ensure => true}
class {'elexis::postgresql_server': ensure => true}
class {'elexis::praxis_wiki': ensure => true}
# class {'elexis::samba': ensure => true}
# class {'elexis::install': ensure => true}
class {'elexis::vagrant': ensure => true}
class {'elexis::windows': ensure => true}
