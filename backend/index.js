require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const http = require('http'); // Import http to create a server
const { Server } = require('socket.io'); // Import Socket.IO

const app = express();
const server = http.createServer(app); // Create the server
const io = new Server(server); // Attach Socket.IO to the server

const PORT = process.env.PORT || 5000;
const HOST = '192.168.0.111'; // Specify your IP address here

// Middleware
app.use(express.json());

// MongoDB connection
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB Atlas');
}).catch(err => {
  console.error('Failed to connect to MongoDB', err);
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('noteUpdated', (note) => {
    // Broadcast the updated note to all connected clients
    socket.broadcast.emit('noteUpdated', note);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Import routes after the app initialization
const authRoutes = require('./routes/authRoutes')(io); // Pass io to authRoutes
const noteRoutes = require('./routes/noteRoutes')(io); // Pass io to the note routes
const taskRoutes = require('./routes/taskRoutes')(io); // Pass io to the task routes

// Use the routes after the middleware
app.use('/auth', authRoutes);
app.use('/notes', noteRoutes);
app.use('/tasks', taskRoutes);

// Basic route
app.get('/', (req, res) => {
  res.send('Notepad-ToDo API is running');
});

// Start the server
server.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
});
