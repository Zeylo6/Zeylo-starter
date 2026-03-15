const { db } = require('./src/config/firebase');
const fs = require('fs');

async function checkAdminActions() {
  const snapshot = await db.collection('admin_actions').get();
  let output = '';
  snapshot.forEach(doc => {
    output += `Action: ${doc.id}\n`;
    output += JSON.stringify(doc.data(), null, 2) + '\n';
    output += '---\n';
  });
  fs.writeFileSync('actions_dump.txt', output);
  console.log('Done');
}

checkAdminActions();
