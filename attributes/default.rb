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
default['postfix']['master']['services'] = [
{'service'=>'smtp', 'type'=>'inet', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'smtpd', ]},
#smtps     inet  n       -       n       -       -       smtpd
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
#628      inet  n       -       n       -       -       qmqpd
{'service'=>'pickup', 'type'=> 'fifo', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '60', 'maxproc' => '1', 'command' => [ 'pickup', ]},
{'service'=>'cleanup', 'type'=> 'unix', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '0', 'command' => [ 'cleanup', ]},
{'service'=>'qmgr', 'type'=> 'fifo', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '300', 'maxproc' => '1', 'command' => [ 'qmgr', ]},
{'service'=>'tlsmgr', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '1000?', 'maxproc' => '1', 'command' => [ 'tlsmgr', ]},
{'service'=>'rewrite', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'trivial-rewrite', ]},
{'service'=>'bounce', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '0', 'command' => [ 'bounce', ]},
{'service'=>'defer', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '0', 'command' => [ 'bounce', ]},
{'service'=>'trace', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '0', 'command' => [ 'bounce', ]},
{'service'=>'verify', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '1', 'command' => [ 'verify', ]},
{'service'=>'flush', 'type'=> 'unix', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '1000?', 'maxproc' => '0', 'command' => [ 'flush', ]},
{'service'=>'proxymap', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'proxymap', ]},
{'service'=>'smtp', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '500', 'command' => [ 'smtp', ]},
{'comment'=>'When relaying mail as backup MX, disable fallback_relay to avoid MX loops', 'service'=>'relay', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'smtp', 
'	-o smtp_fallback_relay=',
'#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5',
]},
{'service'=>'showq', 'type'=> 'unix', 'private' => 'n', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'showq', ]},
{'service'=>'error', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'error', ]},
{'service'=>'discard', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'discard', ]},
{'service'=>'local', 'type'=> 'unix', 'private' => '-', 'unpriv' => 'n', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'local', ]},
{'service'=>'virtual', 'type'=> 'unix', 'private' => '-', 'unpriv' => 'n', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'virtual', ]},
{'service'=>'lmtp', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '-', 'command' => [ 'lmtp', ]},
{'service'=>'anvil', 'type'=> 'unix', 'private' => '-', 'unpriv' => '-', 'chroot' => 'n', 'wakeup' => '-', 'maxproc' => '1', 'command' => [ 'anvil', ]},
{'service'=>'scache', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'-', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'1', 'command' => ['scache',]},

{'comment'=>'Interfaces to non-Postfix software.', 'service'=>'maildrop', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  flags=DRhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}'
]},
{'comment'=>'The Cyrus deliver program has changed incompatibly, multiple times.', 'service'=>'old-cyrus', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  flags=R user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -m ${extension} ${user}',
]},
{'comment'=>"Cyrus 2.1.5 (Amos Gouaux)\n##Also specify in main.cf: cyrus_destination_recipient_limit=1", 'service'=>'cyrus', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  user=cyrus argv=/usr/lib/cyrus-imapd/deliver -e -r ${sender} -m ${extension} ${user}',
]},
{'comment' => 'See the Postfix UUCP_README file for configuration details.', 'service'=>'uucp', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)',
]},
{'comment' => '# Other external delivery methods.', 'service'=>'ifmail', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)',
]},
{'service'=>'bsmtp', 'type'=>'unix', 'private'=>'-', 'unpriv'=>'n', 'chroot'=>'n', 'wakeup'=>'-', 'maxproc'=>'-', 'command' => ['pipe',
'  flags=Fq. user=foo argv=/usr/local/sbin/bsmtp -f $sender $nexthop $recipient',
]},
]

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
