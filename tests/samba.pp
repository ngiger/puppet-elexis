notify { 'test: elexis::samba': }
if (true) {
  class{'elexis::samba': }
} else {
  class{'elexis::samba': 
    ensure => present,
    pdf_ausgabe => true,
    with_x2go => true,
  }
}
