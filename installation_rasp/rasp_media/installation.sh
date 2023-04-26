#!/bin/bash 

## Quelques couleurs pour suivre l'exécution plus facilement
END="\033[0m"
GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"

# script pour rassembler toutes les installations à faire sur la raspberry pi 3 réservée au WEB

echo -e "$GREEN #### Mise à jour du système #### $END"

sudo apt update && sudo apt upgrade -y


# Installation de NodeJS et NPM

echo -e "$GREEN #### Installation du serveur NodeJS et NPM #### $END"

(apt search nodejs | grep "nodejs/stable") | grep "installed" > test

if [ -s test ]
then 
    echo -e "$BLUE NodeJS est déjà installé $END"
else 
    echo -e "$BLUE Installation NodeJS & NPM$END"

    # en superutilisateur, sinon cette fonction ne marche pas
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs 

    # vérification des installations
    echo -e "$BLUE Node JS version ? $END"
    node -v
    echo -e "$BLUE NPM version ? $END"
    npm -v
fi


# installation de VLC

echo -e "$GREEN #### Installation de VLC #### $END"

sudo apt install vlc -y


# création et test d'un projet node JS

if [ ! -d "/home/media/marty" ];then

    echo -e "$GREEN #### Test Projet HELLO dans /home/media/marty #### $END"
    cd /home/media
    mkdir marty && cd marty

    echo -e "$BLUE Installation de git $END"
    sudo apt install git

    echo -e "$BLUE Initialisation du projet $END"
    npm init -y

    echo -e "$BLUE Récupération paquets MQTT et VLC $END"
    npm install --save mqtt vlcplayer-node
    npm install mqtt -g 

    echo -e "$BLUE Création server.js $END"
    echo "function hello() {" > server.js
    echo -e "    console.log(\x60Hello nodejs! \\\n Using \x24{process.version} node version.\x60);" >> server.js
    echo -e "} \\n" >> server.js
    echo "hello();" >> server.js 

    echo -e "$BLUE Contenu du script $END"
    cat server.js

    echo -e "$BLUE Test avec npm start $END"
    npm start
fi

# création du dossier pour stocker les medias : 
sudo mkdir /var/medias && sudo chmod 777 /var/medias


