# Rabbit Sky Docker-compose

## Requirement
- Git
- Docker
- Docker-compose
- Letsencrypt certbot

## Setup
1. first clone web and server repo
```bash
git clone https://github.com/rabbitsky-io/rabbitsky-server
git clone https://github.com/rabbitsky-io/rabbitsky-web
```

2. copy the config file to this dir
```bash
cp ../extra-files/nginx/sites-enabled/https-443.conf nginx.conf
cp ../extra-files/rabbitsky-web/config.json .
```

3. edit the config file
```bash
nano nginx.conf
```
change string from `127.0.0.1` to `rabbitsky-server` and change the root dir
```bash
root        /var/www/rabbitsky; > /usr/share/nginx/html
...


location /channel/ {
    proxy_pass http://127.0.0.1:8080; > http://rabbitsky-server:8080
}

location /channel/join {
    proxy_pass http://127.0.0.1:8080; > http://rabbitsky-server:8080

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
}
```
and change the domain string in nginx.conf and config.json with your domain

3. install ssl 
```bash
certbot certonly --cert-name {{ DOMAIN }} -d {{ DOMAIN }}
```
this command will create ssl key under `/etc/letsencrypt/live/`

4. up docker
```bash
docker-compose up
```