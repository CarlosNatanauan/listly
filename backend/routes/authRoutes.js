module.exports = () => {
  const express = require('express');
  const User = require('../models/user');
  const bcrypt = require('bcrypt');
  const jwt = require('jsonwebtoken');
  const authenticateJWT = require('../middleware/authMiddleware');
  const crypto = require('crypto');
  const nodemailer = require('nodemailer');
  const Note = require('../models/note'); 
  const Task = require('../models/task'); 


  const router = express.Router();
  const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

  // Nodemailer configuration
  const transporter = nodemailer.createTransport({
    service: 'Gmail',
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

    const token = jwt.sign({ id: user._id, passwordChangedAt: user.passwordChangedAt }, JWT_SECRET, { expiresIn: '1d' });
    
    // Add the user's email to the response
    res.json({
      token,
      userId: user._id,
      username: user.username,
      email: user.email // Include the email in the response
    });
  });


  // Get User Data
  router.get('/user', authenticateJWT, async (req, res) => {
    const userId = req.user.id;
    try {
      const user = await User.findById(userId).select('-password');
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.json(user);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  });
  

  // Delete Account
  router.delete('/delete-account', authenticateJWT, async (req, res) => {
    const { email } = req.body;

    try {
      const user = await User.findOneAndDelete({ email: email });

      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      // Delete all notes and tasks associated with this user
      await Note.deleteMany({ userId: user._id });
      await Task.deleteMany({ userId: user._id });

      // Set accountDeletedAt timestamp
      await User.findByIdAndUpdate(user._id, { accountDeletedAt: new Date() });

      res.status(200).json({ message: 'Account and associated data deleted successfully' });
    } catch (error) {
      res.status(500).json({ message: 'Error deleting account', error: error.message });
    }
  });

  // Get Account Deletion Timestamp
  router.get('/account-deleted-at', authenticateJWT, async (req, res) => {
    const userId = req.user.id;
    try {
      const user = await User.findById(userId);
      if (!user) return res.status(404).json({ message: 'User not found' });
      res.status(200).json({ accountDeletedAt: user.accountDeletedAt });
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  });



  // Request OTP for Password Reset
  router.post('/request-reset', async (req, res) => {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'User not found' });

    const currentDate = new Date();
    const todayMidnight = new Date().setHours(0, 0, 0, 0);

    if (user.otpRequestDate && user.otpRequestDate.getTime() >= todayMidnight) {
      if (user.otpRequestCount >= 15) {
        return res.status(429).json({ message: 'You have reached the daily OTP request limit.' });
      } else {
        user.otpRequestCount += 1;
      }
    } else {
      user.otpRequestDate = currentDate;
      user.otpRequestCount = 1;
    }

    const otp = crypto.randomInt(100000, 999999).toString();
    const otpExpiration = Date.now() + 10 * 60 * 1000; // 10 minutes

    user.otp = otp;
    user.otpExpiration = otpExpiration;

    await user.save();

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: user.email,
      subject: 'Password Reset OTP',
      text: `Your OTP is: ${otp}. It will expire in 10 minutes.`
    };

    transporter.sendMail(mailOptions, (error) => {
      if (error) return res.status(500).json({ message: 'Failed to send OTP' });
      res.status(200).json({ message: 'OTP sent' });
    });
  });

  // Verify OTP
  router.post('/verify-otp', async (req, res) => {
    const { email, otp } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'User not found' });

    if (user.otp !== otp) return res.status(400).json({ message: 'Invalid OTP' });

    if (Date.now() > user.otpExpiration) return res.status(400).json({ message: 'OTP expired' });

    res.status(200).json({ message: 'OTP verified' });
  });

  // Change Password
  router.post('/change-password', async (req, res) => {
    const { email, newPassword } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'User not found' });

    const currentTime = Date.now();
    const cooldownPeriod = 24 * 60 * 60 * 1000;

    if (user.lastPasswordChange && currentTime - user.lastPasswordChange < cooldownPeriod) {
      return res.status(403).json({ message: 'You can only change your password once every 24 hours.' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    user.passwordChangedAt = currentTime;

    user.otp = undefined;
    user.otpExpiration = undefined;

    await user.save();

    res.status(200).json({ message: 'Password changed successfully' });
  });

  // Get Password Changed Timestamp
  router.get('/password-changed-at', authenticateJWT, async (req, res) => {
    const userId = req.user.id;
    try {
      const user = await User.findById(userId);
      if (!user) return res.status(404).json({ message: 'User not found' });
      res.status(200).json({ passwordChangedAt: user.passwordChangedAt });
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  });


  // Expire OTP on Exit
  router.post('/expire-otp', async (req, res) => {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'User not found' });

    user.otp = undefined;
    user.otpExpiration = undefined;

    await user.save();

    res.status(200).json({ message: 'OTP expired' });
  });

  return router;
};
