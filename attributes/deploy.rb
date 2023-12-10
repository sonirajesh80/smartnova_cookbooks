include_attribute 'smart_custom::logrotate'
default[:opsworks][:deploy_user][:shell] = '/bin/bash'
default[:opsworks][:deploy_user][:user] = 'deploy'
default[:opsworks][:deploy_keep_releases] = 5

# The deploy provider used. Set to one of
# - "Branch"      - enables deploy_branch (Chef::Provider::Deploy::Branch)
# - "Revision"    - enables deploy_revision (Chef::Provider::Deploy::Revision)
# - "Timestamped" - enables deploy (default, Chef::Provider::Deploy::Timestamped)
# Deploy provider can also be set at application level.
default[:opsworks][:deploy_chef_provider] = 'Timestamped'
# the $HOME of the deploy user can be overwritten with this variable.
default[:opsworks][:deploy_user][:home] = '/home/deploy'
default[:opsworks][:deploy_user][:group] = 'www-data'

default[:deploy] = {}
application=node[:shortname]
Chef::Log.info("Application name:#{application}")
default[:deploy][application][:deploy_to] = "/srv/www/#{application}"
Chef::Log.info("Application deploy_to:#{default[:deploy][application][:deploy_to]}")
default[:deploy][application][:chef_provider] = node[:deploy][application][:chef_provider] ? node[:deploy][application][:chef_provider] : node[:opsworks][:deploy_chef_provider]
default[:deploy][application][:keep_releases] = node[:deploy][application][:keep_releases] ? node[:deploy][application][:keep_releases] : node[:opsworks][:deploy_keep_releases]
default[:deploy][application][:current_path] = "#{node[:deploy][application][:deploy_to]}/current"
default[:deploy][application][:document_root] = ''
default[:deploy][application][:absolute_document_root] = default[:deploy][application][:current_path]
default[:deploy][application][:migrate] = false


# default[:deploy][application][:action] = 'deploy'
default[:deploy][application][:action] = 'sync'
default[:deploy][application][:user] = node[:opsworks][:deploy_user][:user]
default[:deploy][application][:group] = node[:opsworks][:deploy_user][:group]
default[:deploy][application][:shell] = node[:opsworks][:deploy_user][:shell]
default[:deploy][application][:home] = if !node[:opsworks][:deploy_user][:home].nil?
                                          node[:opsworks][:deploy_user][:home]
                                        elsif self[:passwd] && self[:passwd][self[:deploy][application][:user]] && self[:passwd][self[:deploy][application][:user]][:dir]
                                          self[:passwd][self[:deploy][application][:user]][:dir]
                                        else
                                          "/home/#{self[:deploy][application][:user]}"
                                        end
default[:deploy][application][:sleep_before_restart] = 0
default[:deploy][application][:stack][:needs_reload] = true
default[:deploy][application][:enable_submodules] = true
default[:deploy][application][:shallow_clone] = false
default[:deploy][application][:delete_cached_copy] = true
default[:deploy][application][:purge_before_symlink] = ['log', 'tmp/pids', 'public/system', 'uploads']
default[:deploy][application][:create_dirs_before_symlink] = ['pids', 'system', 'config','uploads','log']
default[:deploy][application][:symlink_before_migrate] = {}
default[:deploy][application][:symlinks] = {"system" => "public/system", "pids" => "tmp/pids", "log" => "log", "uploads"=>"uploads"}

default[:deploy][application][:environment_variables] = {}
default[:deploy][application][:ssl_support] = false

