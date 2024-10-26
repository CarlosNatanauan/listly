// routes/feedbackRoutes.js
const express = require('express');
const Feedback = require('../models/feedback');
const authenticateJWT = require('../middleware/authMiddleware'); // User authentication middleware

const router = express.Router();

// Developer API Key - store in environment variables for security
const DEVELOPER_API_KEY = process.env.DEVELOPER_API_KEY;

// Submit Feedback (User Route)
router.post('/submit', authenticateJWT, async (req, res) => {
  const { rating, additionalComments } = req.body;
  const userId = req.user.id; // Assuming the user is authenticated

  try {
    // Validate rating
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    // Create feedback document
    const feedback = new Feedback({
      userId,
      rating,
      additionalComments,
    });

    const savedFeedback = await feedback.save();
    res.status(201).json({ message: 'Feedback submitted successfully', feedback: savedFeedback });
  } catch (err) {
    res.status(500).json({ message: 'Failed to submit feedback', error: err.message });
  }
});

// Developer-Only Route to Retrieve All Feedback
router.get('/all', async (req, res) => {
  const apiKey = req.headers['authorization'];

  // Check if the API key is provided and valid
  if (apiKey !== `Bearer ${DEVELOPER_API_KEY}`) {
    return res.status(403).json({ message: 'Unauthorized access' });
  }

  try {
    // Retrieve all feedback from the database
    const feedbackData = await Feedback.find().populate('userId', 'username email'); // Optionally include user details
    res.status(200).json(feedbackData);
  } catch (err) {
    res.status(500).json({ message: 'Failed to retrieve feedback', error: err.message });
  }
});

// Developer-Only Route to Delete Feedback by ID
router.delete('/delete/:id', async (req, res) => {
  const apiKey = req.headers['authorization'];

  // Check if the API key is provided and valid
  if (apiKey !== `Bearer ${DEVELOPER_API_KEY}`) {
    return res.status(403).json({ message: 'Unauthorized access' });
  }

  try {
    // Find and delete the feedback by ID
    const deletedFeedback = await Feedback.findByIdAndDelete(req.params.id);

    if (!deletedFeedback) {
      return res.status(404).json({ message: 'Feedback not found' });
    }

    res.status(200).json({ message: 'Feedback deleted successfully', feedback: deletedFeedback });
  } catch (err) {
    res.status(500).json({ message: 'Failed to delete feedback', error: err.message });
  }
});

// Developer-Only Route to Delete All Feedback
router.delete('/delete-all', async (req, res) => {
  const apiKey = req.headers['authorization'];

  // Check if the API key is provided and valid
  if (apiKey !== `Bearer ${DEVELOPER_API_KEY}`) {
    return res.status(403).json({ message: 'Unauthorized access' });
  }

  try {
    // Delete all feedback entries
    const result = await Feedback.deleteMany();

    res.status(200).json({ message: 'All feedback deleted successfully', deletedCount: result.deletedCount });
  } catch (err) {
    res.status(500).json({ message: 'Failed to delete all feedback', error: err.message });
  }
});

module.exports = router;
