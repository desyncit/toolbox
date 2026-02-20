#!bin/bash
printf "setting this up son!"
echo "[smtp.gmail.com]:587 <email>@gmail.com:<gmail app pass>" >> sasl_passwd
postmap sasl_passwd
postconf -e  'inet_interfaces = loopback-only'
postconf -e 'relayhost = [smtp.gmail.com]:587'
postconf -e 'local_transport= "error: it disabled bro, sorry"'
sleep 3
echo "3"
echo "2"
echo "1"
printf 'You must be a BAMF, okay finishing this up\n.'
sleep 3
postconf -e 'mydestination= '
postconf -e 'mydomain=$myorigin'
postconf -e 'myorigin=kvm.net'
postconf -e 'smtp_sasl_auth_enable = yes'
postconf -e 'smtp_sasl_security_options = noanonymous'
postconf -e 'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd'
postconf -e 'smtp_tls_security_level = encrypt'
postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt'

printf "sayyy whatttttt, bro this is crazy!!!!\n"
printf " Lets go ahead and enable this craziness\n"

systemclt enable --now postfix

echo "Whhhhhhhhhhhhhattttt uppp mang!!!" | mailx  -s "exit 0" <phone>@vtext.com

echo "This is cool!!! its that engineer status lol #RHCErunthis"
printf "just sent you a text did you get it?"
read ANSWER

if [ "$ANSWER" == "yea" ]; then
  printf "bro that is siiiiiiiiiickkkkk!"

else 
  printf "Well that sucks, try again I guess. hahaha you suck"

