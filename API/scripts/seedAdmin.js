require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const dbConnect = require('../src/config/dbConnect');
const User = require('../src/models/userModel');

function randomCode6() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function generateUniqueCode() {
  // Loop until a non-colliding code is found
  while (true) {
    const code = randomCode6();
    const exists = await User.findOne({ code }).lean();
    if (!exists) return code;
  }
}

async function seedAdmin() {
  await dbConnect();

  const username = 'admin';
  const plainPassword = 'admin@123';

  let user = await User.findOne({ username });

  if (!user) {
    // Create new admin with collision-safe code allocation
    const hashed = await bcrypt.hash(plainPassword, 10);
    let attempts = 0;
    while (attempts < 10) {
      try {
        const code = await generateUniqueCode();
        user = await User.create({
          username,
          password: hashed,
          role: 'admin',
          code
        });
        console.log(`Created admin user: ${username} (code: ${user.code})`);
        break;
      } catch (e) {
        if (e.code === 11000 && e.keyPattern && e.keyPattern.code) {
          attempts++;
          continue; // retry on code collision
        }
        throw e;
      }
    }
    if (!user) throw new Error('Failed to allocate unique code for admin');
  } else {
    // Update existing admin to ensure role/password/code as required
    let changed = false;

    // Ensure role is admin
    if (user.role !== 'admin') {
      user.role = 'admin';
      changed = true;
    }

    // Ensure password is admin@123 (re-hash only if different)
    const matches = await bcrypt.compare(plainPassword, user.password);
    if (!matches) {
      user.password = await bcrypt.hash(plainPassword, 10);
      changed = true;
    }

    // Ensure code exists; allocate collision-safe if missing
    if (!user.code) {
      let attempts = 0;
      while (attempts < 10) {
        try {
          user.code = await generateUniqueCode();
          await user.save();
          changed = false; // already saved
          console.log(`Updated admin code: ${user.code}`);
          break;
        } catch (e) {
          if (e.code === 11000 && e.keyPattern && e.keyPattern.code) {
            attempts++;
            continue;
          }
          throw e;
        }
      }
      if (attempts >= 10) throw new Error('Failed to allocate unique code for existing admin');
    } else if (changed) {
      await user.save();
    }

    console.log(`Admin ensured. Username: ${user.username}, code: ${user.code}`);
  }
}

seedAdmin()
  .then(() => mongoose.disconnect().then(() => process.exit(0)))
  .catch(err => {
    console.error('Seed failed:', err);
    mongoose.disconnect().then(() => process.exit(1));
  });