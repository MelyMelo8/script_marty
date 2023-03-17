#!/bin/sh 

## Quelques couleurs pour suivre l'exécution plus facilement
END="\033[0m"
GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"

# script pour rassembler toutes les installations à faire sur la raspberry pi 3 réservée au WEB

echo "$GREEN #### Mise à jour du système #### $END"

sudo apt update && sudo apt upgrade -y

echo "$GREEN #### Installation Serveur Apache #### $END"

(apt search apache2 | grep "apache2/stable") | grep "installed" > test

if [ -s test ]
then 
    echo "$BLUE Apache est déjà installé $END"
else 

    sudo apt install apache2 -y

    echo "$BLUE ### Configuration des droits ### $END"

    sudo chown -R marty:www-data /var/www/html/
    sudo chmod -R 770 /var/www/html/

    echo "$BLUE ### Vérification Apache Fonctionne ### $END"

    wget -O verif_apache.html http://127.0.0.1
    cat ./verif_apache.html | grep 'It works' > test

    if [ ! -s test ]
    then 
        echo "$RED Apache ne s'est pas correctement installé $END"
        exit 0
    else 
        echo "$BLUE Apache works $END"
    fi 
fi

# Installation de PHP 

PHP_VERSION=8.2

echo "$GREEN #### Installation de PHP version $PHP_VERSION #### $END"

(apt search php$PHP_VERSION-cli | grep "php$PHP_VERSION-cli/bullseye") | grep "installed" > test

if [ -s test ]
then 
    echo "$BLUE PHP $PHP_VERSION est déjà installé $END"
else 
    echo "$BLUE Récupération Repository $END"
    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo tee /etc/apt/trusted.gpg.d/php.gpg
    echo "deb https://packages.sury.org/php/ bullseye main" | sudo tee /etc/apt/sources.list.d/php.list
    sudo apt update

    echo "$BLUE Installation du module FastCGI $END"
    sudo apt install libapache2-mod-fcgid -y

    echo "$BLUE Installation des modules PHP $END"
    sudo apt install php$PHP_VERSION-cli php$PHP_VERSION-fpm \
    php$PHP_VERSION-opcache php$PHP_VERSION-curl php$PHP_VERSION-mbstring \
    php$PHP_VERSION-pgsql php$PHP_VERSION-zip php$PHP_VERSION-xml php$PHP_VERSION-gd -y

    echo "$BLUE Activation configuration php-fpm $END"
    sudo a2enmod proxy_fcgi
    sudo a2enconf php8.2-fpm
    sudo systemctl reload apache2 && echo "Redémarrage d'apache"

    echo "$BLUE Affichage version PHP $END"
    php$PHP_VERSION -v

    echo "$BLUE Pour tester une page php : \n rm /var/www/html/index.html \
    \n echo '<?php phpinfo(); ?>' > /var/www/html/index.php $END"
fi


# Installation de MariaDB

echo "$GREEN #### Installation du SGBD MariaDB #### $END"

(apt search mariadb-server | grep "mariadb-server/stable") | grep "installed" > test

if [ -s test ]
then 
    echo "$BLUE MariaDB est déjà installé $END"
else 
    echo "$BLUE Installation du serveur mariadb $END"
    sudo apt install mariadb-server php8.2-mysql -y

    echo "$BLUE Configuration du mot de passe root $END"
    sudo mysql --user=root --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY 'marty198';"
    sudo mysql --user=root --password=marty198 --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"

    PHPMYADMIN_VERSION=5.2.1
    echo "$BLUE Installation de phpmyadmin version $PHPMYADMIN_VERSION (compatible PHP $PHP_VERSION) $END"
    cd /tmp
    wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && echo "Téléchargement des sources"
    echo "$BLUE Installation unzip $END"
    sudo apt install unzip -y
    echo "$BLUE Désarchive PhpMyAdmin $END"
    unzip phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip
    echo "$BLUE Déplace le contenu dans /usr/share/phpmyadmin $END"
    sudo mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages /usr/share/phpmyadmin

    echo "$BLUE Configuration $END"
    sudo mkdir -p /var/lib/phpmyadmin/tmp
    sudo chown -R www-data:www-data /var/lib/phpmyadmin/
    cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

    openssl rand -base64 32 > blowfish
    # transforme le caractère / en 1 pour éviter les problèmes sur la commande sed qui suit
    sudo sed -i "s/\//1/g" blowfish
    sudo sed -i "s/cfg.'blowfish_secret'. = ''/cfg['blowfish_secret'] = '$(cat blowfish)'/g" /usr/share/phpmyadmin/config.inc.php
    sudo echo "\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" >> /usr/share/phpmyadmin/config.inc.php

    echo "$BLUE Intégration de phpmyadmin à Apache $END"    

    # supposes que vous avez au préalable mis la conf en même temps que le script sur /home/marty
    sudo mv /home/marty/phpmyadmin.conf /etc/apache2/conf-available/

    sudo a2enconf phpmyadmin.conf
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
    sudo apachectl configtest
    sudo systemctl reload apache2 && echo "Redémarrage d'apache"

    echo "$BLUE Activer extension mysqli pour PHP $END"
    sudo phpenmod mysqli
    sudo systemctl reload apache2 && echo "Redémarrage d'apache"

    rm blowfish
fi

# Installation de NodeJS et Yarn

echo "$GREEN #### Installation du gestionnaire de paquet pour JS et CSS #### $END"

(apt search nodejs | grep "nodejs/stable") | grep "installed" > test

if [ -s test ]
then 
    echo "$BLUE NodeJS est déjà installé $END"
else 
    echo "$BLUE Installation NodeJS $END"
    sudo apt install nodejs -y

    echo "$BLUE Récupération repository pour Yarn $END"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update

    echo "$BLUE Installation Yarn $END"
    sudo apt install yarn -y

    echo "$BLUE Yarn version $END"
    yarn --version
fi


# Installation de Mosquitto

echo "$GREEN #### Installation du serveur MQTT Mosquitto #### $END"

(apt search mosquitto | grep "mosquitto/stable") | grep "installed" > test

if [ -s test ]
then 
    echo "$BLUE Mosquitto est déjà installé $END"
else 
    echo "$BLUE Installation Mosquitto $END"
    sudo apt-get install mosquitto mosquitto-clients -y

    echo "$BLUE Configuration $END"
    # à changer le jour où on sécurise MQTT
    sudo echo "allow_anonymous true" > /etc/mosquitto/conf.d/default.conf

    echo "$BLUE Service Mosquitto démarré et set dans les services à démarrer au boot $END"
    sudo systemctl enable mosquitto.service
fi

rm test