const express = require('express');
const Task = require('../models/task');
const authenticateJWT = require('../middleware/authMiddleware');

// Import the WebSocket server (you might need to export it from wsServer.js)
const { wss } = require('../wsServer'); // Assuming you modify wsServer.js to export wss

const router = express.Router();

// Use the authentication middleware for all routes
router.use(authenticateJWT);

// GET request to retrieve all tasks for the authenticated user
router.get('/', async (req, res) => {
  try {
    const tasks = await Task.find({ userId: req.user.id }); // Only get tasks for the authenticated user
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST request to create a new task
router.post('/', async (req, res) => {
  const task = new Task({
    task: req.body.task,
    completed: req.body.completed || false,
    userId: req.user.id // Associate task with the authenticated user
  });

  try {
    const newTask = await task.save();
    res.status(201).json(newTask); // Return the saved task

    // Broadcast the new task to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'create', task: newTask })); // Send new task to clients
      }
    });

  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// GET request to retrieve a specific task by ID
router.get('/:id', async (req, res) => {
  try {
    const task = await Task.findOne({ _id: req.params.id, userId: req.user.id }); // Find the task by ID and user
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT request to update a task by ID
router.put('/:id', async (req, res) => {
  try {
    const updatedTask = await Task.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id }, // Ensure only the owner can update
      { task: req.body.task, completed: req.body.completed },
      { new: true }
    );

    if (!updatedTask) return res.status(404).json({ message: 'Task not found' });
    res.json(updatedTask);

    // Broadcast the updated task to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'update', task: updatedTask })); // Send updated task to clients
      }
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE request to delete a task by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedTask = await Task.findOneAndDelete({ _id: req.params.id, userId: req.user.id }); // Ensure only the owner can delete
    if (!deletedTask) return res.status(404).json({ message: 'Task not found' });
    
    res.json({ message: 'Task deleted' });

    // Broadcast the deleted task ID to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'delete', id: req.params.id })); // Notify clients about deletion
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
