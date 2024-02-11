const express        = require('express');
const { LocalIndex } = require('vectra');
const OpenAI  = require('openai');
let path = require('path');
//import OpenAI from "openai";

const index = new LocalIndex(path.join(__dirname, '..', 'index'));
//const vectra = require("vectra")
//const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');
//const e = require('express');
let formidable = require('express-formidable');


const fs = require('fs');
const pinataSDK = require('@pinata/sdk');
const { normalizePath } = require('@pinata/sdk');

//embeddings
//const tf = require('@tensorflow/tfjs-node');

//const FormData = require('form-data');

//const axios = require("axios");
const key = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJmNjhjNmRmZi1mOGRmLTQzNzUtYjA5Ny1mMTNmNDk0OTk3ODIiLCJlbWFpbCI6ImhiYXJpbDFAaWNsb3VkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImlkIjoiRlJBMSIsImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxfSx7ImlkIjoiTllDMSIsImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxfV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI2ODFmYTNmZThmY2JmZTI5OTJmZSIsInNjb3BlZEtleVNlY3JldCI6IjcxOGRhMWFjMTRkZmNmMjVjMzM2YmZlYTI0MWUzODU2M2U1ZjJjOWNjOGJkNzdiY2RlMWE1OTY4YWQ4ZWJmNmEiLCJpYXQiOjE2ODUyODk0NDZ9.dheuwiicVcI3mM7yMo9voga4Bis7nDu7g5TJocC_xkc"
const pinata = new pinataSDK({ pinataApiKey: "b82caedb6d5641a18b9f", pinataSecretApiKey: "0498ecb8ad008239bfbeb85b90b3a1b93eaecf7ccfc2e1bfc98c6df9a5836d2f"});
const app = express();
//app.use(bodyParser.json())
/*app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "*")
    next()
  });*/
app.use(formidable({
    encoding: 'utf-8',
    
    multiples: true,
    keepExtensions: true// req.files to be arrays of files
}));


let numberOfEvent = 0;
let eventList = []
let deletedEventList = [] //keep track of the deleted events for a certain time 

//event characteristic for queueing 
let eventInfos = [];

//password indexed by user
let userlist = [];

//live connected users
let connectedUser = [
]

//embedding model(custom vector database)
// load model from training in python and use it to predict/ only use the word embedding (see link)
//https://www.tensorflow.org/text/guide/word_embeddings
/*
const loadModel = async() => { //also good for embeddings
    const model = await tf.loadLayersModel('file://path/to/my-model/model.json');
    model.predict(tf.tensor())
}*/
//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

async function boot() {
    if (!await index.isIndexCreated()) {
        await index.createIndex();
    }
}


const api = new OpenAI({apiKey: `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`});


/* Add items
await addItem('apple');
await addItem('oranges');
await addItem('red');
await addItem('blue');
*/
app.listen(8000, () => {  
    console.log('Server.js on localhost:8000');
    boot();
});

//vector db helper functions
async function getVector(text) {
    const response = await api.embeddings.create({
        model: "text-embedding-ada-002",
        input: text,
      });
    return response.data.data[0].embedding;
}

async function addItem(text) { //add item to db
    await index.insertItem({
        vector: await getVector(text),
        metadata: { text }
    });
}


async function queryVectordb(text) { //query with client
    const vector = await getVector(text);
    const results = await index.queryItems(vector, 3); //3 best scores
    if (results.length > 0) {
        for (const result of results) {
            console.log(`[${result.score}] ${result.item.metadata.text}`);
        }
    } else {
        console.log(`No results found.`);
    }
}

app.get('/test', (req, res) => {
    res.send("Connected to server");
    console.log("EVENT: connected");
})

app.get('/events', (req, res) => {
    console.log("EVENT: loading events");
    let connected_users = []
    for (let i=0; i<connectedUser.length; i++) {
        if(connectedUser[i].connected === true) {
            connected_users.push(connectedUser[i].ip)
        }
    }
    res.json({"events": eventList, "connected": connected_users, "eventInfos": eventInfos});
    
})

app.post('/newEvent', (req, res) => {
    console.log("EVENT: New event: " + req.headers.event_name)
    //console.log(req.headers.event_name)
    
    eventList.push(req.headers.event_name)
    eventInfos.push({"sub": req.headers.ip, "name": req.headers.event_name, "id": numberOfEvent, "coords": req.headers.coords, "date": req.headers.date})
    numberOfEvent++;
    //console.log(res)
    res.json({"status": "ok"})
})

app.post('/deleteEvent', (req, res) => {
    //take the index of the event
    const index = eventList.indexOf(req.headers.event_name);
    eventList.splice(index, 1);
    eventInfos.splice(index, 1);
    console.log("DELETED EVENT_infos: " + eventInfos)
    deletedEventList.push(req.headers.event_name);
    numberOfEvent--;
    res.json({"status": "ok"})

})

//users to queue to event
app.post('/queue', (req, res) => {
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            connectedUser[i].events.push(req.headers.id)
            res.send("queued")
        }
    }
})

//unQueue a user from an event
app.post('/unQueue', (req, res) => {
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            const index = connectedUser[i].events.indexOf(req.headers.id);
            connectedUser[i].events.splice(index, 1);
            res.send("unQueued")
        }
    }
})

//add new dispo
app.post('/addDispo', (req, res) => {
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            connectedUser[i].dispo.push(req.headers.date)
            res.send("queued")
        }
    }
})

//list all dispos
app.post('/listDispo', (req, res) => {
    
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            res.json({"dispo": connectedUser[i].dispo})
        }
    }
   
})

//list queued event 

app.post('/queueList', (req, res) => {
    let eventstopush = []
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            let cu = connectedUser[i]
            for (let i =0; i<cu.events.length; i++) {
                console.log(cu.events[i])
                console.log(eventInfos[cu.events[i]])
                for (let j =0; j<eventInfos.length; j++) {
                    if (eventInfos[j].id == cu.events[i]) {
                        eventstopush.push(eventInfos[j]);
                    }
                }
               
            }
        }
    }
    console.log(eventstopush[0])
    
    res.json({"events": eventstopush})
})

//get My posts
app.post('/mypost', (req, res) => {
    let myposts = []
    for (let i =0; i<eventInfos.length; i++) {
        if (eventInfos[i].sub == req.headers.ip) {
            myposts.push(eventInfos[i])
        }
    }
    res.json({"mp":myposts})
})

app.post('/signup', (req, res) => {
    console.log("EVENT: New sign up: " + req.headers.user_name)

    if (!(userlist.includes(req.headers.user_name))) {
        userlist.push(req.headers.user_name);
        //passlist.push(req.headers.password);
        //connectedUser.push(req.headers.ip)
        connectedUser.push({"ip": req.headers.ip, "name": req.headers.user_name, "password": req.headers.password, "accountInfos": {}, "filters": {}, "connected": true, "events": [], "dispo": []})
        console.log("INFO: new user added")
        console.log(connectedUser)
        res.json({"status": "ok"})
    } else {
        console.log("ERROR: User already existing")
        res.json({"status": "1"})
    }
    //save username + password
    
})

app.post('/accountInfos', (req, res) => {
    //displayed in account and in friend tab 
    //name and bio/images(gallery) ==> to back up on ipfs
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            let cu = connectedUser[i]
            cu.accountInfos = {"name": req.headers.name, "bio":req.headers.bio}
            res.send("ok")
        }
    }

})

app.post('/filters', (req, res) => {
    //filters are elements of a connected users, they are displayed in account.dart and used in the main page to generate a list of event
    //filters: age, gender, ==> to back up on ipfs

    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            let cu = connectedUser[i]
            cu.filters = {"sex": req.headers.sex, "age":req.headers.age, "interests": req.headers.interests}
            //addItem(cu.filters.toString()); add item to vector db
            res.send("ok")
        }
    }

    //res.send("ok")
})

//connect if not already connected
app.post('/connect', (req, res) => {
    console.log("EVENT: New Connection: " + req.headers.user_name)

    if (userlist.includes(req.headers.user_name)) {
        let ind = userlist.indexOf(req.headers.user_name)
        if(req.headers.password === connectedUser[ind].password) {
            connectedUser[ind].connected = true
            res.json({"status": "ok"})
        }
        else {
            res.json({"status": "3"})
            console.log("ERROR: Wrong password")
        }
    } else {
        //save username + password
        res.json({"status": "2"})
        console.log("ERROR: No existing users")
        console.log(userlist)
    }
    
})

app.post('/profilePicture', async (req, res) => {
    //const formData = new FormData();
    //let filearray = JSON.parse(req.headers.file)
    //console.log(filearray)
    //console.log(req.body)
    console.log(req.files)
    //console.log(req)
    
    //formData.append('file', JSON.stringify(req.files));
            
    /*const metadata = JSON.stringify({
        name: req.fields.ip,
        keyvalues: { } // account infos... 
        
    });
    formData.append('pinataMetadata', metadata);
    
    const options = JSON.stringify({
        cidVersion: 0,
    })
    formData.append('pinataOptions', options);
    */
    const options = {
        pinataMetadata: {
            name: req.fields.ip,
            keyvalues: { } // account infos... 
        },
        pinataOptions: {
            cidVersion: 0
        }
    };

    try{
        const stream = fs.createReadStream(req.files.file.path);
        const res2 = await pinata.pinFileToIPFS(stream, options)
        console.log(res2)

        res.send("ok")
    } catch(e) {
        console.log(e);
        res.send("ok");
    }
    
})


//get info if already connected
app.post('/connected', (req, res) => {
    console.log("EVENT: New fetch")
    for (let i =0; i<connectedUser.length; i++) {
        if (connectedUser[i].ip == req.headers.ip) {
            if(connectedUser[i].connected == true) {
                res.json(connectedUser[i])
            } else {
                res.json({"status": "5"})
            }
        }
    }
    res.json({"status": "5"})
})


//disconnect
app.post('/disconnect', (req, res) => {
    for (let i=0; i<connectedUser.length; i++) {
        if(connectedUser[i].ip === req.headers.ip) {
            connectedUser[i].connected = false;
            console.log("EVENT: User: " + req.headers.ip + " diconnected")
            res.send("ok")
        }
    }
    
})