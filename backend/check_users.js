const { db } = require('./src/config/firebase');
const fs = require('fs');

async function checkUsers() {
  const snapshot = await db.collection('users').get();
  let output = '';
  snapshot.forEach(doc => {
    const data = doc.data();
    output += `User ID: ${doc.id}\n`;
    output += `Email: ${data.email}\n`;
    output += '---\n';
  });
  fs.writeFileSync('users_dump.txt', output);
  console.log('Done');
}

checkUsers();
