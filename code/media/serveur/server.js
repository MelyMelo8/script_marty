const PlayerController = require('media-player-controller');
const MQTT = require('mqtt');
require('dotenv').config();

// constantes 
const MQTT_HOST = process.env.MQTT_HOST;
const TOPIC_VIDEO_TITRE = process.env.TOPIC_VIDEO_TITRE_ENCOURS;
const TOPIC_VIDEO_ACTION = process.env.TOPIC_VIDEO_ACTION_ENCOURS;
const TOPIC_VIDEO_LIST_DEMANDE = process.env.TOPIC_VIDEO_LIST_DEMANDE;
const TOPIC_VIDEO_LIST_ENVOI = process.env.TOPIC_VIDEO_LIST_ENVOI;

// connection MQTT
const client = MQTT.connect(`mqtt://${MQTT_HOST}`);

// à la connection => souscription aux topics sur lequels on attend des instructions particulières pour l'app
client.on('connect', function () {
    console.log('[MQTT] Connected');

    client.subscribe(TOPIC_VIDEO_TITRE, console.log.bind(console, `[MQTT] Subscribed to topic ${TOPIC_VIDEO_TITRE}`));
    client.subscribe(TOPIC_VIDEO_ACTION, console.log.bind(console, `[MQTT] Subscribed to topic ${TOPIC_VIDEO_ACTION}`));
    client.subscribe(TOPIC_VIDEO_LIST_DEMANDE, console.log.bind(console, `[MQTT] Subscribed to topic ${TOPIC_VIDEO_LIST_DEMANDE}`));
});

// récupération des variables pour la video
var player = null;
let titre = "";

// Ce système sera à améliorer si possible en récupérant directement ce qui est sur la rasp pour pouvoir faire des téléchargements depuis le WEB par exemple.
const mediasHome = process.env.MEDIAS_HOME;
const VIDEOS = {
    martyTF1: `${mediasHome}/tv/MARTY_TF1_20160915.mp4`,
    GOT: `${mediasHome}/serie/Game_of_Thrones.mp4`,
    clip: `${mediasHome}/clip/6.David_Guetta_-_Titanium_ft._Sia.mp4`
}

// actions quand on reçoit les instructions
client.on('message', function(topic, payload){
    const message = payload.toString();
    console.log(`[MQTT] Message received on ${topic} : ${message}`);

    switch(topic){
        case TOPIC_VIDEO_TITRE:
            if (Object.keys(VIDEOS).includes(message)){
                if (titre !== VIDEOS[message]){
                    titre = VIDEOS[message];
                    console.log(`Nouveau Titre : ${titre}`);
                    if(player !== null){
                        player.quit();
                        player = null;
                    } 
                    player = new PlayerController({
                        app: 'vlc',
                        args: ['--fullscreen'],
                        media: titre
                    });
                    player.launch(err => {
                        if(err) return console.error(err.message);
                        console.log('Media player launched');
                    });   
                }
            }
            break;
        case TOPIC_VIDEO_ACTION:
            if(player.on('playback-started', () => {return true;})){
                switch(message){
                    case "play":
                        player.play();
                        break;
                    case "pause": 
                        player.pause();
                        break;
                    default: // STOP
                        player.quit();
                        break;
                }
            }
            break;
        case TOPIC_VIDEO_LIST_DEMANDE:
            client.publish(TOPIC_VIDEO_LIST_ENVOI), JSON.stringify(Object.keys(VIDEOS));
            break;
    }
});