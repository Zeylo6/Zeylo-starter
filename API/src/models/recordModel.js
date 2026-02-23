const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema(
  {
  code: { type: String, required: true }, // user's 6-digit code
    name: { type: String, required: true },
    title: { type: String },
    phoneNumbers: { type: [String], default: [] },
    mails: { type: [String], default: [] },
    website: { type: String },
    company: { type: String },
    photo: { type: String } 
  },
  { timestamps: true }
);

recordSchema.index({ code: 1, createdAt: -1 });

module.exports = mongoose.model('Record', recordSchema);