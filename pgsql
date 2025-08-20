server.js
// server.js
const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const fs = require("fs");
const path = require("path");
const { WebcastPushConnection } = require("tiktok-live-connector");

// Load config
const config = JSON.parse(fs.readFileSync("./config.json", "utf8"));

// Setup Express
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Serve static files
app.use(express.static(path.join(__dirname, "public")));

wss.on("connection", (ws) => {
  console.log("Overlay connected");
});

// Start TikTok live connection
let tiktokConnection = new WebcastPushConnection(config.tiktok.username);

tiktokConnection
  .connect()
  .then((state) => {
    console.log(`Connected to roomId ${state.roomId}`);
  })
  .catch((err) => {
    console.error("Failed to connect:", err);
  });

// Handle TikTok events
tiktokConnection.on("chat", (data) => {
  console.log(`${data.uniqueId}: ${data.comment}`);
  broadcast({ type: "chat", user: data.uniqueId, text: data.comment });
});

tiktokConnection.on("gift", (data) => {
  if (data.repeatEnd == true) {
    console.log(`${data.uniqueId} sent gift: ${data.giftName} x${data.repeatCount}`);
    broadcast({
      type: "gift",
      user: data.uniqueId,
      gift: data.giftName,
      count: data.repeatCount,
      diamonds: data.diamondCount,
    });
  }
});

// Send messages to overlay clients
function broadcast(msg) {
  const json = JSON.stringify(msg);
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(json);
    }
  });
}

// Start server
const PORT = process.env.PORT || 5757;
server.listen(PORT, () => {
  console.log(`Overlay available at http://localhost:${PORT}`);
});
