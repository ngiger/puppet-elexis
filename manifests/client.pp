# Here we define a few packages which are common to all elexis instances
class elexis::client inherits elexis::params {

  include java
  include mysql::client

  # postgresql client # TODO:
}
