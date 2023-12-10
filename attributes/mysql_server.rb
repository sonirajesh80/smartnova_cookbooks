require 'openssl'

root_pw = String.new
while root_pw.length < 20
  root_pw << OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
end
debian_pw = String.new
while debian_pw.length < 20
  debian_pw << OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
end

developer_pw = String.new
while developer_pw.length < 20
  developer_pw << OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
end
node.default[:mysql][:port] = 3306
node.default[:mysql][:version] = '8.0'
node.default[:mysql][:server_root_password] = root_pw
node.default[:mysql][:server_developer_password] = developer_pw