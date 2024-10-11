require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express(); // Initialize the Express app here
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json()); // Use the built-in express.json() instead of body-parser

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

// Import routes after the app initialization
const authRoutes = require('./routes/authRoutes'); // Import auth routes
const noteRoutes = require('./routes/noteRoutes');
const taskRoutes = require('./routes/taskRoutes');

// Use the routes after the middleware
app.use('/auth', authRoutes); // Add this line to use auth routes
app.use('/notes', noteRoutes);
app.use('/tasks', taskRoutes);

// Basic route
app.get('/', (req, res) => {
  res.send('Notepad-ToDo API is running');
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
