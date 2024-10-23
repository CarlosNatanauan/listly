const jwt = require('jsonwebtoken');
const User = require('../models/user');

const authenticateJWT = async (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Get token from Authorization header

  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);

      if (!user) return res.status(401).json({ message: 'User not found' });

      // Check if the token was issued before the last password change
      if (user.passwordChangedAt) {
        const passwordChangedTimestamp = parseInt(user.passwordChangedAt.getTime() / 1000, 10);
        if (decoded.iat < passwordChangedTimestamp) {
          return res.status(401).json({ message: 'Password recently changed. Please log in again.' });
        }
      }

      req.user = user; // Attach user info to request
      next();
    } catch (err) {
      return res.status(403).json({ message: 'Invalid token' });
    }
  } else {
    res.status(401).json({ message: 'Authorization token missing' });
  }
};

module.exports = authenticateJWT;
