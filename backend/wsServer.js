// ws.js
const WebSocket = require('ws');

const initWebSocket = (server) => {
  const wss = new WebSocket.Server({ server });

  wss.on('connection', (ws) => {
    console.log('New client connected'); // Log when a new client connects

    ws.on('message', (message) => {
      console.log(`Received message: ${message}`); // Log received messages
      // Broadcast the message to all connected clients
      wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    });

    ws.on('close', () => {
      console.log('Client disconnected'); // Log when a client disconnects
    });
  });
};

module.exports = initWebSocket;
