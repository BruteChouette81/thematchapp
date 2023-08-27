const express        = require('express');
const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');


const app = express();

let numberOfEvent = 0;
let eventList = []

app.listen(8000, () => {  console.log('Server.js on localhost:8000');});

app.get('/test', (req, res) => {
    res.send("Connected to server");
    console.log("EVENT: connected");
})

app.get('/events', (req, res) => {
    console.log("EVENT: loading events");
    res.json({"events": eventList});
    
})

app.post('/newEvent', (req, res) => {
    console.log("EVENT: New event: " + req.headers.event_name)
    //console.log(req.headers.event_name)
    numberOfEvent++;
    eventList.push(req.headers.event_name)
    //console.log(res)
    res.json({"status": "ok"})
})