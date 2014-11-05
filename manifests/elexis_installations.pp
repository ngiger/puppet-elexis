# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# encoding: utf-8
#
# Add elexis installations (opensource, demoDB) as defined by
# hiera variables elexis::installations::demoDB
# hiera variables elexis::installations::opensource
#
# TODO: medelexis,

# https://tobrunet.ch/2013/01/iterate-over-datastructures-in-puppet-manifests/
class elexis::elexis_installations(
  $opensource  = nil,
  $demoDB  = nil,
) {
  include elexis::common
  include elexis::params
  include elexis::users
  if ($opensource != nil) {
    create_resources(elexis::install,  $opensource, {})
  }
  if ($demoDB != nil) {
    create_resources(elexis::demodb,  $demoDB, {})
  }
}