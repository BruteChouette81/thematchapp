const express        = require('express');
const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');
const e = require('express');


const app = express();

let numberOfEvent = 0;
let eventList = []

//password indexed by user
let userlist = [];
let passlist = [];

//live connected users

let connectedUser = [
]

//in the user db, there is a dict of created and 

app.listen(8000, () => {  console.log('Server.js on localhost:8000');});

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
    res.json({"events": eventList, "connected": connected_users});
    
})

app.post('/newEvent', (req, res) => {
    console.log("EVENT: New event: " + req.headers.event_name)
    //console.log(req.headers.event_name)
    numberOfEvent++;
    eventList.push(req.headers.event_name)
    //console.log(res)
    res.json({"status": "ok"})
})

app.post('/signup', (req, res) => {
    console.log("EVENT: New sign up: " + req.headers.user_name)

    if (!(userlist.includes(req.headers.user_name))) {
        userlist.push(req.headers.user_name);
        //passlist.push(req.headers.password);
        //connectedUser.push(req.headers.ip)
        connectedUser.push({"ip": req.headers.ip, "name": req.headers.user_name, "password": req.headers.password, "connected": true})
        console.log("INFO: new user added")
        console.log(connectedUser)
        res.json({"status": "ok"})
    } else {
        console.log("ERROR: User already existing")
        res.json({"status": "1"})
    }
    //save username + password
    
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