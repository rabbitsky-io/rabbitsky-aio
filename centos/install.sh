#!/bin/bash

if [[ "$EUID" -ne "0" ]]
then
    echo "Error: Please run this script as root or use sudo."
    exit 1
fi

HOST=""
UNSECURE="0"
SSLEMAIL=""
MAXPLAYERS="100"
ADMINPASS=""
EMBEDTYPE=""
EMBEDID=""
EMBEDCHAT="true"

echo
echo "Rabbit Sky Installer"

## HOST
echo
echo "--------------------"
echo "Host"
echo "--------------------"
echo
echo "Please input host / domain that you will use for this server."
echo "Host / Domain must be pointed to this server if you enable SSL"
echo "Example: demo.rabbitsky.io"
echo
while [ -z "$HOST" ]
do
    read < /dev/tty -p "Host: " HOST
done

## SSL
ssl_enable="-"
echo
echo "--------------------"
echo "Enable SSL"
echo "--------------------"
echo
echo "If you disable SSL, you cannot use Twitch Embed due to Twitch Embed Policy."
echo
while [ "$ssl_enable" != "n" ] && [ "$ssl_enable" != "N" ] && [ "$ssl_enable" != "y" ] && [ "$ssl_enable" != "Y" ] && [ "$ssl_enable" != "" ]
do
    read < /dev/tty -p "Enable SSL and create certificate from LetsEncrypt? (Y/N, default: Y): " ssl_enable
done

if [ "$ssl_enable" == "n" ] || [ "$ssl_enable" == "N" ]
then
    UNSECURE=1
fi

## E-mail SSL
if [ "$UNSECURE" -eq "0" ]
then
    echo
    echo "--------------------"
    echo "E-Mail SSL"
    echo "--------------------"
    echo
    echo "Please input your email that will be used for SSL Creation."
    echo "Example: ssl@rabbitsky.io"
    echo
    while [ "$SSLEMAIL" == "" ]
    do
        read < /dev/tty -p "E-Mail: " SSLEMAIL
    done
fi

## Max Players
echo
echo "--------------------"
echo "Max Players"
echo "--------------------"
echo
read < /dev/tty -p "Maximum Players (Default 100): " temp_maxplayer
if [ ! -z "$temp_maxplayer" ]
then
    MAXPLAYERS="$temp_maxplayer"
fi

## Password
temp_pass1=""
temp_pass2=""
echo
echo "--------------------"
echo "Admin Password"
echo "--------------------"
echo
read < /dev/tty -s -p "Server Admin Password (Empty to disable admin): " temp_pass1
echo
if [ "$temp_pass1" != "" ]
then
    read < /dev/tty -s -p "Server Admin Password (Type Again - Confirm):   " temp_pass2
    echo
fi

while [ "$temp_pass1" != "$temp_pass2" ]
do
    echo
    echo "Password is not same, try again."
    echo
    read < /dev/tty -s -p "Server Admin Password (Empty to disable admin): " temp_pass1
    echo
    if [ "$temp_pass1" != "" ]
    then
        read < /dev/tty -s -p "Server Admin Password (Type Again - Confirm):   " temp_pass2
        echo
    fi
done

ADMINPASS="$temp_pass1"

## Embed Type
echo
echo "--------------------"
echo "Embed Type"
echo "--------------------"
echo
while [ "$EMBEDTYPE" != "twitch" ] && [ "$EMBEDTYPE" != "youtube" ]
do
    read < /dev/tty -p "Embed Platform Type (twitch|youtube): " EMBEDTYPE
done

## Embed ID
echo
echo "--------------------"
echo "Embed ID"
echo "--------------------"
echo
if [ "$EMBEDTYPE" == "youtube" ]
then
    echo "Embed ID is a generated ID by YouTube that you see on your url. Example: https://www.youtube.com/watch?v=5qap5aO4i9A"
    echo "Then the Embed ID is: 5qap5aO4i9A"
fi
if [ "$EMBEDTYPE" == "twitch" ]
then
    echo "Embed ID is your username / Twitch URL. Example: https://twitch.tv/monstercat"
    echo "Then the Embed ID is: monstercat"
fi
echo
while [ "$EMBEDID" == "" ]
do
    read < /dev/tty -p "Embed ID: " EMBEDID
done

## Embed Chat
embed_chat_enable="-"
echo
echo "--------------------"
echo "Enable Embed Chat"
echo "--------------------"
echo
while [ "$embed_chat_enable" != "n" ] && [ "$embed_chat_enable" != "N" ] && [ "$embed_chat_enable" != "y" ] && [ "$embed_chat_enable" != "Y" ] && [ "$embed_chat_enable" != "" ]
do
    read < /dev/tty -p "Enable Embed Chat? (Y/N, default: Y): " embed_chat_enable
done

if [ "$embed_chat_enable" == "n" ] || [ "$embed_chat_enable" == "N" ]
then
    EMBEDCHAT="false"
fi

# START!
echo
echo "--------------------"
echo "Start Installation"
echo "--------------------"
echo

# Disable SETENFORCE, most of the time it causing problem with nginx
sed -i 's/\=enforcing/\=disabled/g' /etc/selinux/config
setenforce 0

# Create User and Folder
useradd www
mkdir /var/www/
chown www.www /var/www

# Yum
yum update -y
yum install epel-release -y
yum install git wget nginx -y

# Config Nginx
mkdir -p /etc/nginx/sites-enabled
mkdir -p /etc/nginx/sites-disabled
mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.rabbitsky.backup
mv -f /etc/nginx/sites-enabled/${HOST} /etc/nginx/sites-disabled/${HOST}.rabbitsky.backup
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/nginx/nginx.conf

if [ "$UNSECURE" -eq "0" ]
then
    wget -O /etc/nginx/sites-enabled/${HOST} https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/nginx/sites-enabled/https-80.conf
else
    wget -O /etc/nginx/sites-enabled/${HOST} https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/nginx/sites-enabled/http.conf
fi

sed -i 's/{{DOMAIN}}/'"${HOST}"'/g' /etc/nginx/sites-enabled/${HOST}

# Firewall
iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
if [ "$UNSECURE" -eq "0" ]
then
    iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
fi

# Download Latest Rabbit Sky Server
wget -O /usr/bin/rabbitsky https://github.com/rabbitsky-io/rabbitsky-server/releases/latest/download/rabbitsky-linux-amd64
chmod +x /usr/bin/rabbitsky

# Create Rabbit Sky Service
wget -O /etc/systemd/system/rabbitsky.service https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/systemd/rabbitsky.service
sed -i 's/{{ORIGIN}}/'"${HOST}"'/g' /etc/systemd/system/rabbitsky.service
sed -i 's/{{PASSWORD}}/'"${ADMINPASS}"'/g' /etc/systemd/system/rabbitsky.service
sed -i 's/{{MAXPLAYERS}}/'"${MAXPLAYERS}"'/g' /etc/systemd/system/rabbitsky.service

# Download Latest (master) Rabbit Sky Web
git clone https://github.com/rabbitsky-io/rabbitsky-web.git /var/www/rabbitsky

# Create Rabbit Sky Web Config
config_secure="false"
if [ "$UNSECURE" -eq "0" ]
then
    config_secure="true"
fi

wget -O /var/www/rabbitsky/config.json https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/rabbitsky-web/config.json
sed -i 's/{{EMBEDTYPE}}/'"${EMBEDTYPE}"'/g' /var/www/rabbitsky/config.json
sed -i 's/{{EMBEDID}}/'"${EMBEDID}"'/g' /var/www/rabbitsky/config.json
sed -i 's/{{EMBEDCHAT}}/'"${EMBEDCHAT}"'/g' /var/www/rabbitsky/config.json
sed -i 's/{{HOST}}/'"${HOST}"'/g' /var/www/rabbitsky/config.json
sed -i 's/{{SECURE}}/'"${config_secure}"'/g' /var/www/rabbitsky/config.json

# Change Ownership
chown www.www /var/www/rabbitsky -fR

# Start NGINX and Rabbit Sky
systemctl enable --now rabbitsky
systemctl enable --now nginx

# Set Variable Visit
url_visit="http://${HOST}"

# Lets Encrypt if SSL Enable
if [ "$UNSECURE" -eq "0" ]
then
    mkdir -p /etc/nginx/certs
    mkdir -p /var/www/rabbitsky/.well-known/acme-challenge

    # Change Ownership
    chown www.www /var/www/rabbitsky/.well-known/acme-challenge -fR

    # Install Certbot with Snap
    yum install snapd -y
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
    sleep 10
    snap install core
    snap refresh core
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot

    # Generate SSL Domain
    /usr/bin/certbot certonly -d ${HOST} -a webroot -w /var/www/rabbitsky --non-interactive --agree-tos -m ${SSLEMAIL}

    # Renew Cron Daily at 12 PM
    (crontab -l ; echo "0 12 * * * /usr/bin/certbot renew -d ${HOST} -a webroot -w /var/www/rabbitsky --post-hook \"systemctl reload nginx\"") | crontab -

    # Generate dhparam
    openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048

    # Get SSL Config
    mv -f /etc/nginx/sites-enabled/${HOST}.ssl /etc/nginx/sites-disabled/${HOST}.ssl.rabbitsky.backup
    wget -O /etc/nginx/sites-enabled/${HOST}.ssl https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/extra-files/nginx/sites-enabled/https-443.conf
    sed -i 's/{{DOMAIN}}/'"${HOST}"'/g' /etc/nginx/sites-enabled/${HOST}.ssl

    # Restart NGINX
    systemctl restart nginx

    # Set Variable Visit
    url_visit="https://${HOST}"
fi

echo
echo "--------------------"
echo "Installation Done"
echo "--------------------"
echo
echo "You can now visit your Rabbit Sky on:"
echo "${url_visit}"
echo
echo "Enjoy the sky!"
echo