const express = require('express');
const Note = require('../models/note');
const authenticateJWT = require('../middleware/authMiddleware');

// Import the WebSocket server (you might need to export it from wsServer.js)
const { wss } = require('../wsServer'); // Assuming you modify wsServer.js to export wss

const router = express.Router();

// Use the authentication middleware for all routes
router.use(authenticateJWT);

// POST request to create a new note
router.post('/', async (req, res) => {
  const newNote = new Note({
    title: req.body.title,
    content: req.body.content,
    userId: req.user.id // Associate note with the authenticated user
  });

  try {
    const savedNote = await newNote.save();
    res.status(201).json(savedNote); // Return the saved note

    // Broadcast the new note to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'create', note: savedNote }));
      }
    });

  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// GET request to retrieve all notes for the authenticated user
router.get('/', async (req, res) => {
  try {
    const notes = await Note.find({ userId: req.user.id }); // Only get notes for the authenticated user
    res.json(notes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET request to retrieve a specific note by ID
router.get('/:id', async (req, res) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, userId: req.user.id }); // Find the note by ID and user
    if (!note) return res.status(404).json({ message: 'Note not found' });
    res.json(note);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT request to update a note by ID
router.put('/:id', async (req, res) => {
  try {
    const updatedNote = await Note.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id }, // Ensure only the owner can update
      { title: req.body.title, content: req.body.content },
      { new: true }
    );

    if (!updatedNote) return res.status(404).json({ message: 'Note not found' });
    res.json(updatedNote);

    // Broadcast the updated note to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'update', note: updatedNote }));
      }
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE request to delete a note by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedNote = await Note.findOneAndDelete({ _id: req.params.id, userId: req.user.id }); // Ensure only the owner can delete
    if (!deletedNote) return res.status(404).json({ message: 'Note not found' });
    
    res.json({ message: 'Note deleted' });

    // Broadcast the deleted note ID to all connected WebSocket clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ action: 'delete', id: req.params.id }));
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
