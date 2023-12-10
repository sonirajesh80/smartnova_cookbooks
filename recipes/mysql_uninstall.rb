# Stop MySQL service
service 'mysql' do
    action [:stop, :disable]
end

# Remove MySQL package
package 'mysql-server' do
    action :remove
end

# Clean up MySQL configuration files
file '/etc/mysql/my.cnf' do
    action :delete
end

# Clean up MySQL data directory
directory '/var/lib/mysql' do
    recursive true
    action :delete
end
