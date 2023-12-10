packages = [
    "php8.1",
    "php8.1-common",
    "php8.1-opcache",
    "php8.1-cli",
    "php8.1-gd",
    "php8.1-curl",
    "php8.1-mysql",
    "php8.1-xml",
    "php8.1-xmlrpc",
    "php8.1-dev",
    "php8.1-imap",
    "php8.1-mbstring",
    "php8.1-opcache",
    "php8.1-soap",
    "php8.1-zip",
    "php8.1-intl",
    "libapache2-mod-php8.1"
]
packages.each do |pkg|
    package pkg do
        action :install
        ignore_failure(pkg.to_s.match(/^php-pear-/) ? true : false) # some pear packages come from EPEL which is not always available
        retries 3
        retry_delay 5
        not_if "dpkg -l #{pkg} | grep '^ii'"
    end
end