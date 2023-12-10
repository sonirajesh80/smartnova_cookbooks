apt_update 'update' do
    action :update
end

other_packages = [
    "locales",
    "nano",
    "htop",
    "build-essential",
    "curl",
    "wget",
    "tree",
    "zip",
    "git",
    "mysql-client"
]
other_packages.each do |pkg|
    package pkg do
        action :install
        retries 3
        retry_delay 5
        not_if "dpkg -l #{pkg} | grep '^ii'"
    end
end