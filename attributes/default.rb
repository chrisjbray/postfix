# Author:: Joshua Timberman <joshua@chef.io>
# Copyright:: Copyright 2009-2014, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Generic cookbook attributes
default['postfix']['mail_type'] = 'client'
default['postfix']['relayhost_role'] = 'relayhost'
default['postfix']['multi_environment_relay'] = false
default['postfix']['use_procmail'] = false
default['postfix']['main_template_source'] = 'postfix'
default['postfix']['master_template_source'] = 'postfix'
default['postfix']['sender_canonical_map_entries'] = {}
default['postfix']['smtp_generic_map_entries'] = {}
default['postfix']['access_maps_db_type'] = 'hash'
default['postfix']['alias_maps_db_type'] = 'hash'
default['postfix']['transport_maps_db_type'] = 'hash'
default['postfix']['virtual_alias_maps_db_type'] = 'hash'
default['postfix']['virtual_alias_domains_db_type'] = 'hash'
default['postfix']['hash_files'] = {}
default['postfix']['hash_files']['alias_maps'] = {'postmaster' => 'root'}
#default['postfix']['hash_files']['relay_restrictions'] = {'*' => 'REJECT'} #TODO: Force last

case node['platform']
when 'smartos'
  default['postfix']['conf_dir'] = '/opt/local/etc/postfix'
  default['postfix']['alias_maps_db'] = '/opt/local/etc/postfix/aliases'
  default['postfix']['transport_maps_db'] = '/opt/local/etc/postfix/transport'
  default['postfix']['access_maps_db'] = '/opt/local/etc/postfix/access'
  default['postfix']['virtual_alias_maps_db'] = '/opt/local/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/opt/local/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/opt/local/etc/postfix/relay_restrictions'
when 'freebsd'
  default['postfix']['conf_dir'] = '/usr/local/etc/postfix'
  default['postfix']['alias_maps_db'] = '/etc/aliases'
  default['postfix']['transport_maps_db'] = '/usr/local/etc/postfix/transport'
  default['postfix']['access_maps_db'] = '/usr/local/etc/postfix/access'
  default['postfix']['virtual_alias_maps_db'] = '/usr/local/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/usr/local/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/etc/postfix/relay_restrictions'
when 'omnios'
  default['postfix']['conf_dir'] = '/opt/omni/etc/postfix'
  default['postfix']['alias_maps_db'] = '/opt/omni/etc/postfix/aliases'
  default['postfix']['transport_maps_db'] = '/opt/omni/etc/postfix/transport'
  default['postfix']['access_maps_db'] = '/opt/omni/etc/postfix/access'
  default['postfix']['virtual_alias_maps_db'] = '/etc/omni/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/etc/omni/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/opt/omni/etc/postfix/relay_restrictions'
  default['postfix']['uid'] = 11
else
  default['postfix']['conf_dir'] = '/etc/postfix'
  default['postfix']['alias_maps_db'] = '/etc/aliases'
  default['postfix']['transport_maps_db'] = '/etc/postfix/transport'
  default['postfix']['access_maps_db'] = '/etc/postfix/access'
  default['postfix']['virtual_alias_maps_db'] = '/etc/postfix/virtual'
  default['postfix']['virtual_alias_domains_db'] = '/etc/postfix/virtual_domains'
  default['postfix']['relay_restrictions_db'] = '/etc/postfix/relay_restrictions'
end

# Non-default main.cf attributes
default['postfix']['main']['biff'] = 'no'
default['postfix']['main']['append_dot_mydomain'] = 'no'
default['postfix']['main']['myhostname'] = (node['fqdn'] || node['hostname']).to_s.chomp('.')
default['postfix']['main']['mydomain'] = (node['domain'] || node['hostname']).to_s.chomp('.')
default['postfix']['main']['myorigin'] = '$myhostname'
default['postfix']['main']['mydestination'] = [node['postfix']['main']['myhostname'], node['hostname'], 'localhost.localdomain', 'localhost'].compact
default['postfix']['main']['smtpd_use_tls'] = 'yes'
default['postfix']['main']['smtp_use_tls'] = 'yes'
default['postfix']['main']['smtp_sasl_auth_enable'] = 'no'
default['postfix']['main']['mailbox_size_limit'] = 0
default['postfix']['main']['mynetworks'] = nil
default['postfix']['main']['inet_interfaces'] = 'loopback-only'

# Conditional attributes, also reference _attributes recipe
case node['platform_family']
when 'debian'
  default['postfix']['cafile'] = '/etc/ssl/certs/ca-certificates.crt'
when 'smartos'
  default['postfix']['main']['smtpd_use_tls'] = 'no'
  default['postfix']['main']['smtp_use_tls'] = 'no'
  default['postfix']['cafile'] = '/opt/local/etc/postfix/cacert.pem'
when 'rhel'
  default['postfix']['cafile'] = '/etc/pki/tls/cert.pem'
else
  default['postfix']['cafile'] = "#{node['postfix']['conf_dir']}/cacert.pem"
end

# # Default main.cf attributes according to `postconf -d`
# default['postfix']['main']['relayhost'] = ''
# default['postfix']['main']['milter_default_action']  = 'tempfail'
# default['postfix']['main']['milter_protocol']  = '6'
# default['postfix']['main']['smtpd_milters']  = ''
# default['postfix']['main']['non_smtpd_milters']  = ''
# default['postfix']['main']['sender_canonical_classes'] = nil
# default['postfix']['main']['recipient_canonical_classes'] = nil
# default['postfix']['main']['canonical_classes'] = nil
# default['postfix']['main']['sender_canonical_maps'] = nil
# default['postfix']['main']['recipient_canonical_maps'] = nil
# default['postfix']['main']['canonical_maps'] = nil

# Master.cf attributes
default['postfix']['master']['submission'] = false

# OS Aliases
default['postfix']['aliases'] = case node['platform']
                                when 'freebsd'
                                  {
                                    'MAILER-DAEMON' =>  'postmaster',
                                    'bin' =>            'root',
                                    'daemon' =>         'root',
                                    'named' =>          'root',
                                    'nobody' =>         'root',
                                    'uucp' =>           'root',
                                    'www' =>            'root',
                                    'ftp-bugs' =>       'root',
                                    'postfix' =>        'root',
                                    'manager' =>        'root',
                                    'dumper' =>         'root',
                                    'operator' =>       'root',
                                    'abuse' =>          'postmaster'
                                  }
                                else
                                  {}
                                end

if node['postfix']['use_relay_restirictions_maps']
  default['postfix']['main']['smtpd_relay_restrictions'] = "hash:#{node['postfix']['relay_restrictions_db']}, reject"
end
