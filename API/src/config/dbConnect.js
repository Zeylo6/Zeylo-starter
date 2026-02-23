const mongoose = require('mongoose');

const dbConnect = async () => {
    try {
        const uri = process.env.CONNECTION_STRING;
        if (!uri) {
        console.error('Missing CONNECTION_STRING');
        process.exit(1);
        }
        await mongoose.connect(uri, { serverSelectionTimeoutMS: 15000 });
        console.log('Database connected');
    } catch (e) {
        console.error('Database connection failed:', e.message);
    }
};

module.exports = dbConnect;