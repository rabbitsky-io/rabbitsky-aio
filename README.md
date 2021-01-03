# Rabbit Sky All-In-One Installer

This repository only contains scripts for installing Rabbit Sky Web and Rabbit Sky Server.

Currently the AIO can only install to CentOS, Red Hat, Ubuntu, and Debian OS. For other OS, please do it manually by installing NGINX and creating Service.

**Check out how to install manually here in  [Part 1 - Rabbit Sky Web](https://github.com/rabbitsky-io/rabbitsky-web).**

---

## Requirement

1. **VM / VPS / Server with x64 OS**

    *Minimum: 1 Core, 1 GB Ram, and 1GB Hard Disk Space.*
    *We recommend using a Fresh Server. If you have things on your server already, consider installing it manually.*

2. **Public IP**

    *Must be attached to the **VM / VPS / Server (1)**.*

3. **Domain / Subdomain**

    *Must be pointed to the **Public IP (2)**.*

## Installation

This installer will install:

1. [Nginx Web Server](https://nginx.org/)
2. [Git Client](https://git-scm.com/)
3. [Wget Command](https://www.gnu.org/software/wget/)
4. [Rabbit Sky Web Assets](https://github.com/rabbitsky-io/rabbitsky-web)
5. [Rabbit Sky Server](https://github.com/rabbitsky-io/rabbitsky-server)

If you're enabling SSL, the installer will also install:
1. [Snapd](https://snapcraft.io/)
2. [Certbot](https://certbot.eff.org/)

Additional for CentOS / Red Hat:
1. EPEL Repository

## Install Command

### CentOS / Red Hat

Non-root User (Using Sudo):

```
curl -s -L https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/redhat/install.sh | sudo bash
```

Root User:

```
curl -s -L https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/redhat/install.sh | bash
```

### Ubuntu / Debian

Non-root User (Using Sudo):

```
curl -s -L https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/debian/install.sh | sudo bash
```

Root User:

```
curl -s -L https://raw.githubusercontent.com/rabbitsky-io/rabbitsky-aio/master/debian/install.sh | bash
```


### Other OS

Currently, we don't have any knowledge outside these 4 OSs.

If you understand bash / shell script and know how to install things, we are happy to receive your merge request!

## User Input

The script will ask you multiple questions like Host, E-Mail for SSL, Admin Password etc. Since we don't want to validate anything due to language compability, please make sure your input is right and valid. Wrong value can cause the script run unsuccessfully.

Here are the inputs:
| Input | Default Value | Description |
| ----- | ------------- | ----------- |
| Host  | | Your Domain / Subdomain that pointed to your server ip. Must be valid host, without the scheme (http:// or https://). Example: demo.rabbitsky.io |
| SSL Enable | Y | Enable SSL and Create SSL Cert using Lets Encrypt (Certbot). Value: Y / N |
| SSL E-Mail | | E-Mail you will be used for creating SSL Cert. Must be valid and active E-Mail, this will be sent to Lets Encrypt Server and any info regarding LetsEncrypt will be sent to this email. Example: ssl@rabbitsky.io |
| Max Players | 100 | Maximum Players that Rabbit Sky Server handle. Default is 100. Number Only. Example: 200 |
| Admin Password | | Password for using /admin command in game. If you choose to disable admin command, you can leave this input empty. NOTE: This password stored plainly. Consider to create a new simple one, and not using your own password. |
| Admin Password - Confirm | | Must be same as Admin Password, for confirmation purpose. |
| Embed Type | | Choose Live Stream Platform. All undercase. Value: twitch / youtube. |
| Embed ID | | ID of the embed video. For Twitch, you can use the channel name: twitch.tv/monstercat, so the value is the `monstercat`. For YouTube Live, you can use the id in the url: youtube.com/watch?v=5qap5aO4i9A, so the value is the `5qap5aO4i9A`. |
| Embed Chat | Y | Show embed live chat on the right side of the game. Value: Y / N  |
## Frequently Asked Questions (FAQ)

#### I don't have sudo rights or I cannot use root user. How can I install it?
You cannot use this script without root permission. You still can install it manually. Check out how to install manually here in  [Part 1 - Rabbit Sky Web](https://github.com/rabbitsky-io/rabbitsky-web).

#### My server already have nginx installed, can I use this script?
We recommend you to not using this script if you have anything installed on your current server. But you still can install it, we created config backup for `nginx.conf` and `sites-enabled`. You can check files with ending `.rabbitsky.backup`.

#### I already have SSL Certificate, can I use it instead?
If you already have certificate, you still have to create letsencrypt cert so the validation is finished. After the installation is done, you can change your script in `/etc/nginx/sites-enabled/your.domain.com`.

If you insists to not using letsencrypt, you can modify the script as you like.

#### I cannot access my website!
Please check your domain and your ip is configured right.

Also you can check your server firewall settings. We tried to allow port 80 (and 443 if you enable SSL), but sometime it doesn't work on some server.

#### I don't want to use SSL, is HTTP fine?
If you're using YouTube Live, it's fine. But you cannot use Twitch Stream because their policy.

#### I have other question!
You can contact us on E-Mail, Discord, etc. Check out [Our Website](https://rabbitsky.io).

## Donate
Liking this and having a spare of money? Consider donating!

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/wibisaja)

## Contributing

Yes