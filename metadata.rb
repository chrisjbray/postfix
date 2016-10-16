name 'postfix'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Installs and configures postfix for client or outbound relayhost, or to do SASL auth'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '4.0.0'

recipe 'postfix', 'Installs and configures postfix'
recipe 'postfix::sasl_auth', 'Set up postfix to auth to a server with sasl'
recipe 'postfix::client', 'Searches for the relayhost based on an attribute'
recipe 'postfix::server', 'Sets the mail_type attribute to master'

%w(ubuntu debian redhat centos amazon oracle scientific smartos fedora).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/postfix'
issues_url 'https://github.com/chef-cookbooks/postfix/issues'

chef_version '>= 12.1' if respond_to?(:chef_version)
