#!/bin/bash

# Varaibles
PEM1="example.com.key"
PEM2="example.com.crt"
DOMAIN="example.com"
DOMAINCONF="/etc/httpd/conf.d/$DOMAIN.conf"
ALIAS=www.example.com
DOCROOT=/var/www/example.com/
CERTFILE=/etc/ssl/certs/vhosts/$PEM2
KEYFILE=/etc/pki/tls/private/vhosts/$PEM1

# functions

httpd () {
printf "Setting up Virtual host $DOMAIN\n"

mkdir -p /var/www/$DOMAIN
mkdir -p /var/log/httpd/vhosts/$DOMAIN

httpd_conf () {

systemctl enable httpd
systemctl start httpd

cat <<EOF>> /etc/httpd/conf.d/$DOMAIN.conf
<VirtualHost *:80>
	ServerName 		$DOMAIN
	ServerAlias 	$ALIAS
	DocumentRoot 	$DOCROOT

	RewriteEngine	On
	RewriteRule 	^/?(.*)	https://example.com
</VirtualHost>

<VirtualHost *:443>
	ServerName 				$DOMAIN
	ServerAlias 			$ALIAS
	DocumentRoot 			$DOCROOT
	Errorlog 				logs/vhosts/$DOMAIN.error
	Accesslog				logs/httpd/vhosts/$DOMAIN.access combined

	SSLEngine				On
	SSLCertificateFile		$CERTFILE
	SSLCertificateKeyFile	$KEYFILE
	SSLProtocol				all -SSLv2 -SSLv3
	
</VirtualHost>
EOF

printf "Configuring firewalld\n"

firewall-cmd --add-service={http,https} --perm
firewall-cmd --reload

printf "Port is now open on the default zone\n"
printf "Checking configuration of server\n"

httpd -t

if [ $# -gt 0 ]; then
	printf "hmmm looks like something went wrong\n"
	printf "Please check the configurations done in the path below:\n"
	printf "$DOMAINCONF\n"
else
	printf "Configuration looks good, reloading httpd process\n"
	systemctl reload httpd
fi
}

httpd_install () {

printf "Installing httpd and SSL compenents\n"

yum -y httpd mod_ssl

if [ $# -gt 0 ]; then
	printf "hmm looks like something went wrong, please check network and repo settings\n"
else
	printf "httpd packages installed\n"
fi
}

self-sign () {

printf "Generating Self-Signed Cert\n"
mkdir -p /etc/pki/tls/certs/vhosts
mkdir -p /etc/pki/tls/private/vhosts

if [ $# -gt 0 ]; then 
		printf  "hmmm something went wrong check the paths in the script to ensure they exsist\n"
	exit 1
else
	sleep 3
	/usr/bin/openssl req -newkey rsa:2048 -keyout /etc/pki/tls/private/vhosts/$PEM1 -nodes -x509 -days 365 -out /etc/pki/tls/certs/vhosts/$PEM2
	printf  "Updating trust store\n"
	yum install ca-certificates -y
	cp /etc/pki/tls/certs/vhosts/$PEM2 /etc/pki/ca-trust/source/anchors/
	update-ca-trust extract

# Retore SELinux Context labels for consistency
	printf "Setting context labels for consistency\n"
	restorecon -RvF /etc/pki/tls/{certs,private}/vhosts/* 2> /dev/null
	printf "Done\n"
fi

}

}



# Functions end


# start of script

# Ensure running as root

if [[ $EUID -ne 0 ]]; then

	printf "Error, this script needs superuser powers , please run as root"
else

rpm -q httpd mod_ssl

	if [ $? -eq 0 ]; then
		httpd
		httpd_conf
		self-sign
		printf "httpd is configured and should be running with ssl self-signed cert enabled\n"

	else
		httpd
		httpd_install
		httpd_conf
		self-sign
		printf "httpd is configured and should be running with ssl self-signed cert enabled\n"

	fi
fi

