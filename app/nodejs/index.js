const express = require('express');
const webpush = require('web-push');
const parser = require('body-parser');
const path = require('path');

//Initialize Values

let likes = [];
let users = [];

const port = process.env.port || 5000;

//Push Notification

const app = express();
const server = require('http').createServer(app);
const io = require('socket.io').listen(server);

app.use(parser.json());

const publicVapidKey = 'BI3v4icYrq4C81vp-KmViHia0hQJ2QB-t4k_z32zyo_cRE-Fcd4EmYHFEPnEvNbbOAXGQQTObSOGiKpmAbqJMLg';
const privateVapidKey = 'zhAd5Po58hcUg15rtNXdPSKGbQxd3amOiSNrizNCWj8';

webpush.setVapidDetails('mailto:irchristianscott@gmail.com', publicVapidKey, privateVapidKey);

server.listen(port, () => console.log("Running at Port " + port));

app.post('/notification/subscribe', (request, response) => {
	const subscription = request.body.subscription
	response.status(201).json({})

	const payload = JSON.stringify(request.body.data);
	webpush.sendNotification(subscription, payload).catch(error => console.error(error));
});

//WebSockets

io.on("connection", function(socket){

	socket.on("comment", function(comment){
		io.emit("getComment", comment)
	});

	socket.on("connected", function(user){
		users.push(user);
		socket.emit("getconnected", users);
	});

	socket.on("like", function(like){
		io.emit("getLike", like);

		likes.forEach((l) => {
			if(l.liker !== like.liker){
				likes.push(like);
			}
		});
	});

	socket.on("rlike", function(like){
		io.emit("rgetLike", like);
	});

	socket.on("textType", function(data){
		io.emit("isTyping", data);
	});

	socket.on("messageSent", function(message){
		io.emit("getMessage", message);
	});

	socket.on("adminMessageSent", function(message){
		io.emit("getAdminMessage", message);
	});

	socket.on("followUser", function(user){
		io.emit("getFollower", user);
	});

	socket.on("setNotification", function(data){
		io.emit("getNotification", data);
	});

	socket.on("suggestion", function(suggestion){
		io.emit("getSuggestion", suggestion);
	});

	socket.on("updateSuggestion", function(status){
		io.emit("getSuggestionUpdate", status);
	});

	socket.on("notify", function(data){
		io.emit("getNotify", data);
	});
});

