//importing modules

const express = require("express");
const http = require("http")
require('dotenv').config(); 
const mongoose = require("mongoose");

const app = express();

const port = process.env.PORT || 3000;
var server = http.createServer(app);
const Room = require("./models/room");
var io = require("socket.io")(server);

//middle ware 
app.use(express.json());

const DB = process.env.MONGO_CONNECTION;

io.on("connection", (socket) => {
    console.log("Conected socket!");
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
            if (!roomId.match(/^[a-zA-Z0-9]{10}$/)) {
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

    socket.on('tap', async ({ index, roomId }) => {
        try {
            let room = await Room.findById(roomId);
            let choice = room.turn.playerType; //x or o
            if (room.turnIndex == 0) {
                room.turn = room.players[1];
                room.turnIndex = 1;
            } else {
                room.turn = room.players[0];
                room.turnIndex = 0;
            }
            room = await room.save();
            io.to(roomId).emit("tapped", {
                index,
                choice,
                room,
            });
        } catch (e) {
            console.log(e);
        }
    })

    

    socket.on("winner", async ({ winnerSocketId, roomId}) => {
        try {
            if (socket.id != winnerSocketId) { return; }
            let room = await Room.findById(roomId);
            let player = room.players.find(
                (playerr) => playerr.socketID == winnerSocketId
            );
            player.points += 1;
            room.currentRound += 1;
            room = await room.save();

            if (player.points >= room.maxRounds) {
                
                io.to(roomId).emit("endGame", player);
                await Room.deleteOne({ id: roomId }, function(err) {
                    if (err) {
                      console.log(err);
                    } else {
                      console.log('Room deleted successfully');
                    }
                  });
            } else {
                //too winner's socket id and made sure only the winner's device will increase the round 
                //otherwise both devices were updating the round
                //same logic was also used for the points increment
                //io.to(winnerSocketId).emit("roundIncrease", { currentRound: room.currentRound }); //this will shows the new round number in winner's device only
                io.to(roomId).emit("roundIncrease", { currentRound: room.currentRound }); //This will emit the roundIncrease event to all sockets in the roomId room, except for the socket that triggered the event (in this case, the winner's socket).
                console.log('Received increaseCurrentRound event for room', roomId);
                io.to(roomId).emit("pointIncrease", player);
            }
        } catch (e) {
            console.log(e);
        }
    });


    socket.on("reset", async ({roomId}) =>  {
        
        // Clear the game state data from MongoDB
      await Room.deleteOne({ id: roomId }, function(err) {
        if (err) {
          console.log(err);
        } else {
          console.log('Room deleted successfully');
        }
      });
    });

    
});

async function resetGame(roomId) {
    try {
      let room = await Room.findById(roomId);
      
      // reset players' points to zero
      room.players.forEach(player => {
        player.points = 0;
      });
      
      // set game status back to "not started"
      room.gameStarted = false;
      
      // save changes to the database
      await room.save();
      
      console.log(`Game in room ${roomId} has been reset.`);
    } catch (e) {
      console.log(`Error resetting game in room ${roomId}: ${e.message}`);
    }
  }

mongoose.set("strictQuery", false);//deprecated warning otherwise
mongoose.connect(DB).then(() => {
    console.log("Connection successful!")
}).catch((e) => {
    console.log(e);
});

server.listen(port, '0.0.0.0', () => {
    console.log(`Server started and running on port ${port}`)
});

const keepAlive = () => {
    console.log('Sending keep-alive request to server...');
    const options = {
        hostname: 'https://tictactoe-mp-backend.onrender.com',
        port: 80,
        path: '/',
        method: 'GET'
    };

    const req = http.request(options, (res) => {
        console.log(`statusCode: ${res.statusCode}`);
        res.on('data', (d) => {
            process.stdout.write(d);
        });
    });

    req.on('error', (error) => {
        console.error(error);
    });

    req.end();
    
};

// call the function every 5 minutes
setInterval(keepAlive, 13 * 60 * 1000);



   // socket.on("winner", async ({ winnerSocketId, roomId}) => {
    //     try {
    //       let room = await Room.findById(roomId);
    //       let player = room.players.find(
    //         (playerr) => playerr.socketID == winnerSocketId
    //       );
          
      
    //       if (player.points >= room.maxRounds) {
    //         // Store the ID of the winning player's socket in the game room object
    //         room.winnerSocketId = winnerSocketId;
    //         await room.save();
      
    //         // Emit the endGame event only to the winning player
    //         io.to(winnerSocketId).emit("endGame", player);
      
    //         // Delete the game room from the database
    //         await Room.deleteOne({ _id: roomId });
    //       } else {
    //         io.to(roomId).emit("pointIncrease", player);
    //       }
    //     } catch (e) {
    //       console.log(e);
    //     }
    //   });

    // socket.on('increaseCurrentRound', async ({ roomId }) => {
    //     try {
    //         console.log('Received increaseCurrentRound event for room', roomId);
    //       const room = await Room.findById(roomId);
    //       room.currentRound+= 1;
    //       await room.save();
    //       io.to(roomId).emit('updateRoom', room);
    //     } catch (e) {
    //       console.log(e);
    //     }
    //   });