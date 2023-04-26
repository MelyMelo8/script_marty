tout le code y compris les assets qui sont pour l'instant un ensemble de vidéo sont à placer sur la rasp MEDIA dans /home/media/marty avec la commande scp :        

> cd /[all_chemin_before_git]/code/media    
> scp -r assets media@[ip-wifi]:/home/media         
> scp -r serveur media@[ip-wifi]:/home/media    

REMARQUE : Par soucis de place mémoire sur le git, les videos choisi seront mise sur le drive canapé connecté.    

Ensuite, le .env.dist est à copier dans un fichier .env où il faut mettre à jour l'ip MQTT_HOST avec l'ip wifi de la rasp WEB, ainsi sur la rasp en connexion ssh :         

> ssh media@[ip-wifi]       

On supprime l'ancien dossier devenu obsolète avec nos modifications que l'on veut mettre à la place     
> sudo rm -Rf marty     
> mv serveur marty       

On copie les vidéo dans un endroit facile à retrouver mais qui ne nécessite pas de transporter les vidéos à chaque mise à jour du code.     
> sudo mv assets/ /var/medias   

On prépare le serveur       
> cd marty      

Le fichier d'environnement : Attention à changer l'ip HOST MQTT par l'ip de la rasp web sur le routeur du canapé        
> cp .env.dist .env     
> nano .env         

charge les librairies JS nécessaires        
> npm install       

démarre le serveur      
> npm start         
