service 'apache2' do
action :nothing
only_if { ::File.exist?('/etc/init.d/apache2') && ::File.executable?('/etc/init.d/apache2') }
end

apache2_install 'default_install' do
action :install
notifies :restart, 'apache2_service[default]', :immediately
not_if { ::File.exist?('/etc/init.d/apache2') && ::File.executable?('/etc/init.d/apache2') }
end

apache2_module 'headers' do
action :enable
notifies :reload, 'apache2_service[default]'
end

apache2_default_site 'smartnova_site' do
default_site_name 'smartnova'
template_cookbook 'smart_custom'
port '80'
template_source 'web_app.conf.erb'
action :enable
notifies :reload, 'apache2_service[default]'
end

apache2_service 'default' do
action [:enable, :start]
end
