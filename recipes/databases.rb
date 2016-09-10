# Copyright:: Copyright (c) 2012, Chef Software, Inc.
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
#
# rubocop: disable Lint/ParenthesesAsGroupedExpression

node['postfix']['hash_files'].each do |db, values|
  if node['postfix']["#{db}_db"]
    path = node['postfix']["#{db}_db"]
  else
    path = "#{node['postfix']['conf_dir']}/#{db}"
  end
  node.default_unless['postfix']['main'][db] = ["hash:#{path}"]
  execute "update-postfix-#{db}" do
    command "postmap #{path}"
    environment ({ 'PATH' => "#{ENV['PATH']}:/opt/omni/bin:/opt/omni/sbin" }) if platform_family?('omnios')
    # On FreeBSD, /usr/sbin/newaliases is the sendmail command, and it's in the path before postfix's /usr/local/bin/newaliases
    environment ({ 'PATH' => "/usr/local/bin:#{ENV['PATH']}" }) if platform_family?('freebsd') and db == "aliases"
    action :nothing
  end

  separator = ' '
  if db == 'alias_maps' then
    separator = ': '
  end
  template path do
    source 'db.erb'
    variables ({:entries => values, :separator => separator})
    notifies :run, "execute[update-postfix-#{db}]"
    notifies :restart, 'service[postfix]'
  end
end

include_recipe 'postfix::_common'
