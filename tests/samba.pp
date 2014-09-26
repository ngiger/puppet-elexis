notify { 'test: elexis::samba': }
class{"elexis::samba": ensure => present }
# class {"elexis::samba": ensure => present}
