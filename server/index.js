//importing modules
const express = require("express");
const http = require("http")
const mongoose = require("mongoose");

const app = express();

const port = process.env.PORT || 3000;
var server = http.createServer(app);
const Room = require("./models/room");
var io = require("socket.io")(server);

//middle ware 
app.use(express.json());

const DB = "mongodb+srv://MrFreez18:123456789Ab@cluster0.gng6vna.mongodb.net/?retryWrites=true&w=majority";

io.on("connection", (socket) => {
    console.log("Conected!");
    socket.on("createRoom", async ({ nickname }) => {
        console.log(nickname);
        console.log(socket.id);
        try {

            //room is created
            let room = new Room();
            let player = {
                socketID: socket.id,
                nickname,
                playerType: 'X',
            };
            room.players.push(player);
            room.turn = player;
            room = await room.save();
            console.log(room);
            const roomId = room._id.toString();

            socket.join(roomId);
            //player is stored in the room
            //player is taken to the next screen

            //tell the client that rom is created and go to next screen
            io.to(roomId).emit("createRoomSuccess", room);
        } catch (e) {
            console.log(e);
        }


    });

    socket.on('joinRoom', async ({ nickname, roomId }) => {
        try {
            if (!roomId.match(/^[0-9a-fA-F]{24}$/)) {
                socket.emit("errorOccurred", "Please enter a valid room ID.");
                return;
            }
            let room = await Room.findById(roomId);

            if (room.isJoin) {
                let player = {
                    nickname,
                    socketID: socket.id,
                    playerType: "O",
                };
                socket.join(roomId);
                room.players.push(player);
                room.isJoin = false;
                room = await room.save();
                io.to(roomId).emit("joinRoomSuccess", room);
                io.to(roomId).emit("updatePlayers", room.players);
                io.to(roomId).emit("updateRoom", room);
            } else {
                socket.emit(
                    "errorOccurred",
                    "The game is in progress, try again later."
                );
            }
        } catch (e) {
            console.log(e)
        }
    })
});

mongoose.set("strictQuery", false);//deprecated warning otherwise
mongoose.connect(DB).then(() => {
    console.log("Connection successful!")
}).catch((e) => {
    console.log(e);
});

server.listen(port, '0.0.0.0', () => {
    console.log(`Server started and running on port ${port}`)
});