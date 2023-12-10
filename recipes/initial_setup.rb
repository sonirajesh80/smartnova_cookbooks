require 'resolv'
os_release =
  if rhel7?
    os_release = File.read("/etc/redhat-release").chomp
  else
    `head -1 /etc/issue | sed -e 's/ \\\\.*//'`.chomp
  end

template "/etc/motd" do
  source "motd.erb"
  cookbook "smart_custom"
  mode "0644"
  variables({
    :instance => node[:instance],
    :os_release => os_release
  })
end

template '/etc/hosts' do
  source "hosts.erb"
  cookbook "smart_custom"
  mode "0644"
  variables(
    :localhost_name => node[:instance][:hostname],
    :nodes => search(:node, "name:*")
  )
end

template '/etc/security/limits.conf' do
    source 'limits.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    cookbook 'smart_custom'
  end

  directory "/etc/sysctl.d" do
    mode 0755
    owner "root"
    group "root"
    action :create
  end
  
  template "/etc/sysctl.d/70-smart-defaults.conf" do
    mode 0644
    owner "root"
    group "root"
    source "sysctl.conf.erb"
    cookbook "smart_custom"
  end
  
  node[:initial_setup][:sysctl].each do |systcl, value|
    execute "Setting sysctl: #{systcl}" do
      command "sysctl -w #{systcl}=#{value}"
      action :run
      ignore_failure true
    end
  end