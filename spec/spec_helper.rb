require 'puppetlabs_spec_helper/module_spec_helper'

NrResourcesInElexisCommon = 10
WheezyFacts = { :osfamily => 'Debian',
                :operatingsystem => 'Debian',
                :operatingsystemrelease => 'wheezy',
                :lsbdistcodename => 'wheezy',
                :lsbdistid => 'debian',
                # for thias/samba
                :selinux => false,
                # for mysql
                :root_home => '/root',
                # for wget
                :http_proxy => nil,
                :https_proxy => nil,
                :kernel => 'Linux',
                # for java
                :architecture => 'amd64',
                 # for concat/manifests/init.pp:193
                :id => 'id',
                :concat_basedir => '/opt/concat',
                :path => '/path',
                }

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.default_facts = WheezyFacts
  c.config = '/doesnotexist'
end

#at_exit { RSpec::Puppet::Coverage.report! }
