define elexis::puppet_java (
  
) {

  class{'java':
      distribution => 'wheezy',
      version      => 'openjdk-7',
  }
}