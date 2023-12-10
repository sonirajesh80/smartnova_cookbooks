# Stop Apache service
service 'apache2' do
    action [:stop, :disable]
end

# Remove Apache package
package 'apache2' do
    action :remove
end

# Clean up Apache configuration files
directory '/etc/apache2' do
    recursive true
    action :delete
end

# Clean up Apache data directory
# directory '/srv/www' do
#     recursive true
#     action :delete
# end
  