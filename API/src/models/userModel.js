const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },          // hashed only
  role: { type: String, required: true, enum: ['admin', 'user'] },
  code: { type: String, required: true, unique: true }  // 6-digit unique code
}, { timestamps: true });

userSchema.index({ code: 1 }, { unique: true });

module.exports = mongoose.model('User', userSchema);