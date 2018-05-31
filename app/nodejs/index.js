const http = require('http').createServer()
const io = require('socket.io')(http);

http.listen(5000, function(){
	console.log("Running at Port 5000")
});

io.on("connection", function(socket){

	socket.on("comment", function(comment){
		io.emit("getComment", comment)
	});

	socket.on("like", function(like){
		io.emit("getLike", like);
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

});

