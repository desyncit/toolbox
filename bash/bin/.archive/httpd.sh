#!/bin/bash

# Replace the example.com with your domain name in the variables below. Also please ensure either your DNS server/provider/</etc/hosts> file is up to datem as example.com
# is a real domain registered on the internet. 
# PLEASE UPDATE THE DOMAIN IN THE SCRIPT YOU WANT TO USE AS WELL AS DNS BEFORE RUNNING THIS SCRIPT
# if using this script for learning okay to leave as, but make sure you put an entry in the /etc/hosts file 

# Example
# echo "x.x.x.x  example.com  www.example.com" >> /etc/hosts

# Varaibles
DOMAIN="example.com"
DOCROOT="/var/www/$DOMAIN/"
DOMAINCONF="/etc/httpd/conf.d/$DOMAIN.conf"
ALIAS="www.$DOMAIN"
PEM1="$DOMAIN.key"
PEM2="$DOMAIN.crt"
CERTFILE="/etc/ssl/certs/vhosts/$PEM2"
KEYFILE="/etc/pki/tls/private/vhosts/$PEM1"

# functions
packages () {
printf "Downloading all needed packages for this to work properly\n"
	
	for i in httpd mod_ssl ca-certificates; do 
		rpm -q $i | awk -F " " '{print $2}'
			if [[ $i == $1 ]]; then
				yum install -y $1
			else
				printf "$i is installed\n"
			fi
	done
}	

httpd () {
	printf "Setting up Virtual host $DOMAIN\n"
		mkdir -p /var/www/$DOMAIN
		mkdir -p /var/log/httpd/vhosts/$DOMAIN


httpd_conf () {
	systemctl enable httpd
	systemctl start httpd

	cat <<EOF>> /etc/httpd/conf.d/$DOMAIN.conf
		<VirtualHost *:80>
		        ServerName	$DOMAIN
		        ServerAlias	$ALIAS
		        DocumentRoot    $DOCROOT
		        Errorlog        "logs/vhosts/$DOMAIN_error"
		        Customlog   	"logs/vhosts/$DOMAIN_access" combined

		        RewriteEngine   	On
			RewriteCondition	!= %{HTTPS}
		        RewriteRule     	^/?(.*) https://%{HTTP_HOST}%{REQUEST_URI}
		</VirtualHost>

		<VirtualHost *:443>
		        ServerName              $DOMAIN
		        ServerAlias             $ALIAS
		        DocumentRoot            $DOCROOT

		        SSLEngine               On
		        SSLCertificateFile	$CERTFILE
		        SSLCertificateKeyFile   $KEYFILE
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
	        cp /etc/pki/tls/certs/vhosts/$PEM2 /etc/pki/ca-trust/source/anchors/
	        update-ca-trust extract
fi

}

}


# Functions end


# start of script

# Ensure running as root

printf "Heeeyyy, okay what is the domain name of the virtual host you want to configure?\n"
read DOMAIN


if [[ $EUID -ne 0 ]]; then

        printf "Error, this script needs superuser powers , please run as root"
else

rpm -q httpd mod_ssl

        if [ $? -eq 0 ]; then
                httpd
                httpd_conf
                self-sign
                # Retore SELinux Context labels for consistency
                printf "Resotoring default SELinux context labels for consistency\n"
                restorecon -RvF /etc/pki/tls/{certs,private}/vhosts/* 2> /dev/null
                restorecon -RvF /var/www/$DOMAIN/* 2> /dev/null
                printf "httpd is configured and should be running with ssl self-signed cert enabled\n"

        else
            	httpd
		packages                
                httpd_conf
                self-sign
                printf "Resotoring default SELinux context labels for consistency\n"
                restorecon -RvF /etc/pki/tls/{certs,private}/vhosts/* 2> /dev/null
                restorecon -RvF /var/www/$DOMAIN/* 2> /dev/null
                printf "httpd is configured and should be running with ssl self-signed cert enabled\n"

        fi
fi

