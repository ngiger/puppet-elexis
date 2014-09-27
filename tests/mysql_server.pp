notify { 'test: elexis::mysql_server': }
class {'elexis::mysql_server': ensure => 'present' }
