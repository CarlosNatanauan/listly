// models/Note.js
const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  title: { type: String, required: false },  // Title is no longer required
  content: { type: String, required: true },  // Content is still required
  createdAt: { type: Date, default: Date.now },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' } // Reference to the User
});


module.exports = mongoose.model('Note', noteSchema);
