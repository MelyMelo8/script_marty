# Mise en place Raspberry WEB

Cette raspberry héberge le serveur WEB pour l'interface sur la tablette qui doit être accessible pour tout appareil connecté au réseau du canapé. Elle doit pouvoir communiquer facilement avec la rasp multimédia pour lancer un média audio et/ou visuel. Mais cette dernière doit disposer d'une certaine indépendance pour faire tourner le média même si la première rasp crash, d'où le choix d'ajouter un serveur MQTT au canapé.    

Ce README contient l'historique de toutes les commandes ayant permis d'installer l'OS de la Rasp WEB.   

## Choix de l'OS sur "Raspberry Pi Imager v1.7.3"

>RASPBERRY PI OS LITE (32 bit)

On choisi l'OS **Lite**, car elle est moins volumineuse que la version graphique et ne contient pas d'élément par défaut inutile comme minecraft ... On a choisi celle en 32 bit car bien que la 64 bit soit plus performante, les raspberry du canapé sont en 32 bit... C'est aussi la dernière version de Debian donc la Bullseye (Debian 11)       

Ensuite, on configure les paramètres important de la raspberry pi dans les paramètres de imager (*si on oubli, on peut la configurer après mais en branchant la rasp à un clavier et un écran et la commande suivante pour ouvrir la configuration :* 
> sudo raspi-config

*menus Interface / ssh et Localisation / Timezone*). Les paramètres importants à configurer sont : ouverture du port **ssh**, **identifiant / mdp**, **timezone** Paris, **keyboard** français pour avoir le clavier Azerty. voici les identifiant/mdp de la raspberry WEB :           
> username = marty  
> password = marty1983     

Enfin, après avoir "write" l'OS sur la carte SD de la rasp, on va dans **Disks** pour changer la taille mémoire de la partition "roofts" et prendre tout l'espace disponible.  

Ensuite, on peut brancher la rasp sur le canapé pour s'y connecter en ssh. Attention, l'ip est fourni par le wifi donc le routeur. 

> ssh marty@[ip_wifi]

À présent, vous pouvez suivre la version courte ou la version détaillée permettant d'installer tous les paquets pour le serveur WEB de la rasp. Les deux versions donnent le même résultat.

# Version courte (un script pour tout faire)

Il faut au préalable connaître l'adresse IP de la raspberry fourni par le routeur ou le wifi si vous l'installer de chez vous. Chez moi, l'adresse était : 192.168.1.175. Ensuite, une fois la rasberry booté. Vous pouvez envoyer le script [installation.sh](installation.sh) et le fichier de configuration [phpmyadmin.conf](phpmyadmin.conf) sur la raspberry depuis un terminal sur votre ordinateur :     
> scp installation_rasp/rasp_web/phpmyadmin.conf marty@192.168.1.175:/home/marty    
> scp installation_rasp/rasp_web/installation.sh marty@192.168.1.175:/home/marty    

Ensuite, connecter vous en ssh sur la raspberry :   
> ssh marty@192.168.1.175   

Et lancer le script :   
> chmod +x installation.sh      
> ./installation.sh

**REMARQUE**:   
- Le mot de passe de la raspberry est 'marty1983' comme configuré juste après l'installation de l'OS    
- L'exécution de l'installation dure environ 30 min     
- Une partie de l'installation donne un résultat très moche sur le terminal (copie des sources de PHP8), c'est normal ^.^"

# Version détaillée (commande par commande)

## Installation Serveur WEB

### Installation d'Apache

> sudo apt update && sudo apt upgrade -y    
> sudo apt install apache2  

Configuration des droits au dossier d'apache permettant d'administrer les sites
> sudo chown -R marty:www-data /var/www/html/   
> sudo chmod -R 770 /var/www/html/  

Vérifier qu'apache fonctionne 
> wget -O verif_apache.html http://127.0.0.1    
> cat ./verif_apache.html | grep "It works"     

### Installation de PHP 8.2

REMARQUE : cette version de PHP est sortie le 08/12/22 et est maintenue jusqu'au 08/12/25.      

Ajouter le repository PHP   
> wget -q https://packages.sury.org/php/apt.gpg -O- | sudo tee /etc/apt/trusted.gpg.d/php.gpg       
> echo "deb https://packages.sury.org/php/ bullseye main" | sudo tee /etc/apt/sources.list.d/php.list   
> sudo apt update  

**Si vous avez une erreur de apt** : "The method driver /usr/lib/apt/methods/https could not be found"
> sudo apt install ca-certificates apt-transport-https      

Installation du module FastCGI (plus d'info : https://apero-tech.fr/les-differents-modes-dexecution-de-php-cgi-vs-fastcgi-vs-module-apache/)    
> sudo apt install libapache2-mod-fcgid

Installation de PHP 8.2 et des modules courants     
> sudo apt install php8.2-cli php8.2-fpm \      
> php8.2-opcache php8.2-curl php8.2-mbstring \      
> php8.2-pgsql php8.2-zip php8.2-xml php8.2-gd  

Pour trouver d'autre module php8 : *apt search php8*    

Activation de la configuration php-fpm  
> sudo a2enmod proxy_fcgi   
> sudo a2enconf php8.2-fpm   
> sudo systemctl reload apache2     

Tester l'installation de PHP :  
> php8.2 -v    

Ce qui donne si tout va bien :  
> PHP 8.2.4 (cli) (built: Mar 16 2023 14:37:38) (NTS)   
> Copyright (c) The PHP Group   
> Zend Engine v4.2.4, Copyright (c) Zend Technologies   
> &nbsp;   &nbsp; with Zend OPcache v8.2.4, Copyright (c), by Zend Technologies     

Tester une page PHP en récupérant les infos PHP :   
> rm /var/www/html/index.html   
> echo "\<?php phpinfo(); ?>" > /var/www/html/index.php  

Puis ouvrir dans le navigateur : http://[ip_wifi]/

Pour info, les fichiers de configuration par défaut sont : 
- /etc/php/8.2/fpm/php-fpm.conf 
- /etc/php/8.2/fpm/php.ini

Remarques: 
- un des avantages de fpm : peut supporter plusieurs versions de php en même temps, peut donc simplifier une migration de PHP à l'avenir et simplifier les retours en arrière si besoin. 
- ayant besoin de faire tourner une seule interface web, on va garder la configuration par défaut des vhosts. Si à l'avenir, vous souhaiter avoir plusieurs interfaces, vous pouvez configurer des vhost en changeant les ports (par exemple si vous voulez faire tourner une api sur un autre port que l'interface, ou différencier des interfaces d'accès avec des sécurités différentes...). 


## Installation d'un SGBD pour pouvoir gérer des BDD si besoin

Installer MySQL 
> sudo apt install mariadb-server php8.2-mysql  

Vérifier que MySQL fonctionne et changer le mot de passe root
> sudo mysql --user=root    
> ALTER USER 'root'@'localhost' IDENTIFIED BY 'marty198';   
> GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;      

**Installation de PhpMyAdmin** pour simplifier la gestion de bdd, on ne peut pas utiliser la version d'apt, elle contient des erreurs de compatibilité avec PHP 8.2, il faut la version 5.2.1 (https://www.phpmyadmin.net/news/), pour connaître la version de phpmyadmin :     
> dpkg -l phpmyadmin  &nbsp; &nbsp; &nbsp;# Celle d'apt est la  5.0.4.  
   
Télécharger les sources 
> cd /tmp   
> wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip     

> sudo apt install unzip    
> unzip phpMyAdmin-5.2.1-all-languages.zip      
> sudo mv phpMyAdmin-5.2.1-all-languages /usr/share/phpmyadmin      
> sudo mkdir -p /var/lib/phpmyadmin/tmp     
> sudo chown -R www-data:www-data /var/lib/phpmyadmin/      

Pour le fichier de configuration    
> cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php   
> openssl rand -base64 32   
> nano /usr/share/phpmyadmin/config.inc.php     

**On rempli la variable "blowfish_secret" avec le nombre généré par openssl**       

On ne rempli pas les données controluser et controlpass car on a déjà configurer l'utilisateur root avec mysql.

**On déclare le dossier temporaire précédemment créé en ajoutant la variable "TempDir"** :     
> $cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';

Ensuite on sauvegarde et ferme le fichier de configuration.     

Intégration de PhpMyAdmin à Apache 
> sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf

> sudo a2enconf phpmyadmin.conf      
> sudo apachectl configtest   

**En cas de warning** : "*AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message*" 
> sudo nano /etc/apache2/apache2.conf  

On ajoute à la fin :    
> ServerName localhost

Ensuite, on redemarre Apache
> sudo systemctl reload apache2     

Activer l'extention msqli pour pouvoir communiquer avec PHP     
> sudo phpenmod mysqli      
> sudo systemctl reload apache2 

Vérifier l'installation de PhpMyAdmin : http://[ip_wifi]/phpmyadmin


## Installation d'un gestionnaire de paquet JS et CSS 

Les plus connus sont npm (Node Package Manager) et yarn. On utilisera yarn car il est plus rapide que npm.

Installer NodeJS
> sudo apt install nodejs -y    

Installation de yarn 
> curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -        
> echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list        
> sudo apt update   
> sudo apt install yarn -y  

Yarn version
> yarn --version    
> \# 1.22.19

## Serveur MQTT avec Mosquitto

Installation de mosquitto
> sudo apt-get install mosquitto mosquitto-clients      

Service à faire tourner au démarrage de la rasp
> sudo systemctl enable mosquitto.service

Vérification du status 
> sudo service mosquitto status

**Configuration pour simplifier les développements.** Il serai bien de l'améliorer avec des utilisateurs prédéfinis (identifiants et passwords) pour sécuriser la communication. 
> sudo nano /etc/mosquitto/conf.d/default.conf

Et écrire la configuration permettant de se connecter anonymement à MQTT et sur l'ip wifi de la rasp web serveur : 
> allow_anonymous true      
> listener 1883

On redémarre le service 
> sudo service mosquitto restart