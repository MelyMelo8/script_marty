# Mise en place Raspberry MEDIA

Cette raspberry héberge l'ensemble des medias video, image et son disponibles pour le canapé, ainsi qu'un serveur NodeJS en écoute sur le MQTT du serveur de la raspberry WEB pour exécuter les instructions particulières. Ainsi, cette rasp est autonome pour faire tourner une vidéo et ne suivra que les instructions play, pause, stop mais n'aura pas besoin de la rasp web pour le reste.

Ce README contient l'historique de toutes les commandes ayant permis d'installer l'OS de la Rasp MEDIA.   

## Choix de l'OS sur "Raspberry Pi Imager v1.7.3"

>RASPBERRY PI OS (32 bit)

On choisi l'OS classique avec Desktop, car c'était le seul moyen pour que VLC fonctionne correctement. On a choisi celle en 32 bit car bien que la 64 bit soit plus performante, les raspberry du canapé sont en 32 bit... C'est aussi la dernière version de Debian donc la Bullseye (Debian 11)       

Ensuite, on configure les paramètres important de la raspberry pi dans les paramètres de imager (*si on oubli, on peut la configurer après mais en branchant la rasp à un clavier et un écran et la commande suivante pour ouvrir la configuration :* 
> sudo raspi-config

*menus Interface / ssh et Localisation / Timezone*). Les paramètres importants à configurer sont : ouverture du port **ssh**, **identifiant / mdp**, **timezone** Paris, **keyboard** français pour avoir le clavier Azerty. voici les identifiant/mdp de la raspberry WEB :           
> username = media  
> password = media1983     

Enfin, après avoir "write" l'OS sur la carte SD de la rasp, on va dans **Disks** pour changer la taille mémoire de la partition "roofts" et prendre tout l'espace disponible.  

Ensuite, on peut brancher la rasp sur le canapé pour s'y connecter en ssh. Attention, l'ip est fourni par le wifi donc le routeur. 

> ssh media@[ip_wifi]

À présent, vous pouvez suivre la version courte ou la version détaillée permettant d'installer tous les paquets pour le serveur WEB de la rasp. Les deux versions donnent le même résultat.

# Version courte (un script pour tout faire)

Il faut au préalable connaître l'adresse IP de la raspberry fourni par le routeur ou le wifi si vous l'installer de chez vous. Chez moi, l'adresse était : 192.168.1.175. Ensuite, une fois la rasberry booté. Vous pouvez envoyer le script [installation.sh](installation.sh) sur la raspberry depuis un terminal sur votre ordinateur :     
> scp installation_rasp/rasp_web/phpmyadmin.conf media@192.168.1.175:/home/media    

Ensuite, connecter vous en ssh sur la raspberry :   
> ssh media@192.168.1.175   

Et lancer le script :   
> chmod +x installation.sh    
> sudo su  
> root# ./installation.sh
> root# exit

Remarque, l'une des fonctions du script ne fonctionne quand super utilisateur ainsi, soit vous passez tout le script en super utilisateur, soit vous suivez la version longue de ce Readme.

**REMARQUE**:   
- Le mot de passe de la raspberry est 'media1983' comme configuré juste après l'installation de l'OS    
- L'exécution de l'installation dure environ 30 min   

# Version détaillée (commande par commande)

## Installation du serveur NodeJS et d'un gestionnaire de paquet JS et CSS 

Les plus connus sont npm (Node Package Manager) et yarn. On utilisera npm car il est mieux documenté. 

Installer NodeJS & NPM
> sudo su
> root# curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
> root# exit
> node -v # v20.0.0
> npm -v  # 9.6.4


## Installation d'un lecteur multimedia : VLC

Avant, OMXPlayer était un lecteur développé pour raspbian, mais il n'est plus maintenu, par conséquent, VLC semble un choix plus adapté. D'autant qu'après vérification, il existe une librairie node js pour gérer vlc. 

> sudo apt install vlc


## Initialisation et mise en place du serveur NodeJS

> cd /home/media
> mkdir marty && cd marty

Installation de GIT pour faire fonctionner l'initialisation du projet
> sudo apt install git

Initialisation du serveur
> npm init -y

Récupération des librairies JS nécessaires (pour VLC et MQTT)
> npm install --save mqtt media-player-controller

Script Hello Word pour vérifier que le serveur fonctionne ^.^
> echo "function hello() {" > server.js       
> echo -e "    console.log(\x60Hello nodejs! \\\n Using \x24{process.version} node version.\x60);" >> server.js     
> echo -e "} \\n" >> server.js      
> echo "hello();" >> server.js      
> cat server.js     

Vous devriez obtenir le résultat suivant : 
> function hello() {        
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log(`Hello nodejs!\nUsing ${process.version} node version.`);        
> }         
>       
> hello();      

Ensuite, on démarre le serveur pour vérifier le résultat et initialiser la commande start de yarn : 
> node server.js
> npm start

Vous devriez avoir : 
> Hello nodejs! 
>  Using v20.0.0 node version.
