require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const { Server } = require('socket.io');
const https = require('https'); // Add https module for pinging

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const PORT = process.env.PORT || 5000;

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
    socket.broadcast.emit('noteUpdated', note);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Routes
const authRoutes = require('./routes/authRoutes')();
const noteRoutes = require('./routes/noteRoutes')(io);
const taskRoutes = require('./routes/taskRoutes')(io);
const feedbackRoutes = require('./routes/feedbackRoutes');

app.use('/auth', authRoutes);
app.use('/notes', noteRoutes);
app.use('/tasks', taskRoutes);
app.use('/feedback', feedbackRoutes);

// Basic route
app.get('/', (req, res) => {
  res.send('Notepad-ToDo API is running');
});

// Ping route to keep the app active
app.get('/ping', (req, res) => {
  res.status(200).send('pong');
});

// Self-ping function to prevent app from sleeping
setInterval(() => {
    https.get('https://listly-ocau.onrender.com/ping', (res) => {
        console.log(`Ping response: ${res.statusCode}`);
    }).on('error', (err) => {
        console.error('Error pinging:', err.message);
    });
}, 5 * 60 * 1000); // Ping every 5 minutes

// Start the server
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
