const http = require('http').createServer()
const io = require('socket.io')(http);

const port = process.env.port || 5000;

let likes = [];

http.listen(port, function(){
	console.log("Running at Port " + port);
});

io.on("connection", function(socket){

	socket.on("comment", function(comment){
		io.emit("getComment", comment)
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
});

