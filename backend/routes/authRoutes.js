// routes/authRoutes.js
const express = require('express');
const User = require('../models/user');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const authenticateJWT = require('../middleware/authMiddleware'); // Import the JWT authentication middleware
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// Nodemailer configuration
const transporter = nodemailer.createTransport({
  service: 'Gmail', // Or use another email service
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

// User Registration
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  const user = new User({
    username,
    email,
    password: hashedPassword,
  });

  try {
    const savedUser = await user.save();
    res.status(201).json(savedUser);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// User Login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  const user = await User.findOne({ username });
  if (!user) return res.status(400).json({ message: 'User not found' });

  const isValidPassword = await bcrypt.compare(password, user.password);
  if (!isValidPassword) return res.status(400).json({ message: 'Invalid credentials' });

  const token = jwt.sign({ id: user._id }, JWT_SECRET);
  res.json({ token, userId: user._id, username: user.username }); // Include the username
});

// Get User Data
router.get('/user', authenticateJWT, async (req, res) => {
  const userId = req.user.id; // Get user ID from JWT payload
  try {
    const user = await User.findById(userId).select('-password'); // Exclude the password
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});


//--------------------------

  // Request OTP for Password Reset --------------------
  router.post('/request-reset', async (req, res) => {
    const { email } = req.body;

    // Check if the user exists
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    // Check if user has exceeded daily OTP request limit
    const currentDate = new Date(); // Get the current date and time
    const todayMidnight = new Date().setHours(0, 0, 0, 0); // Get today's date at midnight

    console.log("Current Date:", currentDate);
    console.log("Today Midnight:", todayMidnight);
    console.log("User OTP Request Date:", user.otpRequestDate);
    console.log("User OTP Request Count:", user.otpRequestCount);

    // Check if the user has made a request today
    if (user.otpRequestDate && user.otpRequestDate.getTime() >= todayMidnight) {
      // User has already made a request today, check the count
      if (user.otpRequestCount >= 10) {
        return res.status(429).json({ message: 'You have reached the daily OTP request limit.' });
      } else {
        // Increment the count
        user.otpRequestCount += 1;
      }
    } else {
      // Reset the count and update the request date
      user.otpRequestDate = currentDate; // Update to current date
      user.otpRequestCount = 1; // Reset to 1 for the first request of the day
    }

    // Generate a 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();

    // Set OTP expiration (10 minutes from now)
    const otpExpiration = Date.now() + 1 * 60 * 1000;

    // Update user with OTP and expiration
    user.otp = otp;
    user.otpExpiration = otpExpiration;

    // Save the user object after all updates
    await user.save();

    // Send OTP email
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: user.email,
      subject: 'Password Reset OTP',
      text: `Your OTP is: ${otp}. It will expire in 10 minutes.`
    };

    transporter.sendMail(mailOptions, (error) => {
      if (error) {
        return res.status(500).json({ message: 'Failed to send OTP' });
      }
      res.status(200).json({ message: 'OTP sent' });
    });
  });



// Verify OTP --------------------
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  // Find the user by email
  const user = await User.findOne({ email });

  if (!user) {
    return res.status(400).json({ message: 'User not found' });
  }

  // Check if the OTP matches
  if (user.otp !== otp) {
    return res.status(400).json({ message: 'Invalid OTP' });
  }

  // Check if the OTP has expired
  if (Date.now() > user.otpExpiration) {
    return res.status(400).json({ message: 'OTP expired' });
  }

  // OTP is valid
  res.status(200).json({ message: 'OTP verified' });
});

// Change Password --------------------
router.post('/change-password', async (req, res) => {
  const { email, newPassword } = req.body;

  // Find the user by email
  const user = await User.findOne({ email });
  if (!user) {
    return res.status(400).json({ message: 'User not found' });
  }

  const currentTime = Date.now();
  const cooldownPeriod = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

  // Check if the user is allowed to change the password (based on cooldown)
  if (user.lastPasswordChange && currentTime - user.lastPasswordChange < cooldownPeriod) {
    return res.status(403).json({ message: 'You can only change your password once every 24 hours.' });
  }

  // Hash the new password
  const hashedPassword = await bcrypt.hash(newPassword, 10);

  // Update the user's password and record the time of change
  user.password = hashedPassword;
  user.lastPasswordChange = currentTime;

  // Clear OTP and expiration after successful password change
  user.otp = undefined;
  user.otpExpiration = undefined;

  await user.save();

  res.status(200).json({ message: 'Password changed successfully' });
});

// Expire OTP on Exit --------------------
router.post('/expire-otp', async (req, res) => {
  const { email } = req.body;

  const user = await User.findOne({ email });
  if (!user) {
    return res.status(400).json({ message: 'User not found' });
  }

  // Expire the OTP by removing it
  user.otp = undefined;
  user.otpExpiration = undefined;
  await user.save();

  res.status(200).json({ message: 'OTP expired' });
});

module.exports = router;
