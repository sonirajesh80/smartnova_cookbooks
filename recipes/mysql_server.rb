service 'mysql' do
    action :nothing
    only_if { ::File.exist?('/etc/init.d/mysql') && ::File.executable?('/etc/init.d/mysql') }
end

mysql_service 'default' do
    port node[:mysql][:port]
    version node[:mysql][:version]
    initial_root_password node.default[:mysql][:server_root_password] 
    action [:create, :start]
    not_if { ::File.exist?('/etc/init.d/mysql') && ::File.executable?('/etc/init.d/mysql') }
end

if !File.exist?('/etc/init.d/mysql')
    sql_query = <<-EOH
      UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';
      CREATE USER 'developer'@'%' IDENTIFIED BY '#{node.default[:mysql][:server_developer_password]}';
      GRANT ALL PRIVILEGES ON *.* TO 'developer'@'%' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
    EOH
  
    Chef::Log.info("mysql root password:#{node.default[:mysql][:server_root_password]}")
    Chef::Log.info("mysql developer password:#{node.default[:mysql][:server_developer_password]}")
end
  

mysql_database 'mysql' do
    host 'localhost'
    user 'root'
    password node.default[:mysql][:server_root_password] 
    sql sql_query
    action :query
    not_if { ::File.exist?('/etc/init.d/mysql') && ::File.executable?('/etc/init.d/mysql') }
end
