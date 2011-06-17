# Adapted by Niklaus Giger from 
# http://blogs.cae.tntech.edu/mwr/2008/02/05/stupid-puppet-trick-agreeing-to-the-sun-java-license-with-debconf-preseeds-and-puppet/
# Thanks!

class elexis::jre6 {
  package { "sun-java6-jre":
    require      => File["/var/cache/debconf/jre6.seeds"],
    responsefile => "/var/cache/debconf/jre6.seeds",
    ensure       => latest;
  }

  file { "/var/cache/debconf/jre6.seeds":
    content => "
sun-java6-bin   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jdk   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jre   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jre   sun-java6-jre/stopthread        boolean true
sun-java6-jre   sun-java6-jre/jcepolicy note
sun-java6-bin   shared/error-sun-dlj-v1-1       error
sun-java6-jdk   shared/error-sun-dlj-v1-1       error
sun-java6-jre   shared/error-sun-dlj-v1-1       error
sun-java6-bin   shared/present-sun-dlj-v1-1     note
sun-java6-jdk   shared/present-sun-dlj-v1-1     note
sun-java6-jre   shared/present-sun-dlj-v1-1     note
",
    ensure => present;
  }
}

