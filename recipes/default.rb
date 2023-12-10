
Chef::Log.level=:info
include_recipe 'smart_custom::initial_setup'
include_recipe 'smart_custom::custom_packages'
Chef::Log.info("custom packages installed")
include_recipe 'smart_custom::apache2'
Chef::Log.info("apache2 packages installed")
include_recipe 'smart_custom::php'
Chef::Log.info("php packages installed")
include_recipe 'smart_custom::mysql_server'
Chef::Log.info("mysql_server packages installed")
include_recipe 'smart_custom::deploy'