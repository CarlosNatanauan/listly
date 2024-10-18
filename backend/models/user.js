// models/user.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // Store hashed passwords
  email: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now },
  
  // Fields for OTP-based reset
  otp: { type: String }, // 6-digit OTP
  otpExpiration: { type: Date }, // OTP expiration time (e.g., 10 minutes)
  otpRequestCount: { type: Number, default: 0 }, // Number of OTP requests in a day
  otpRequestDate: { type: Date }, // Last OTP request date to enforce daily limits
  lastPasswordChange: { type: Date } // To track the last password change for limiting password resets
});

module.exports = mongoose.model('User', userSchema);
