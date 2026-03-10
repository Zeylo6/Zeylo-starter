const { db } = require('./src/config/firebase');
const fs = require('fs');

async function checkReports() {
  const snapshot = await db.collection('reports').get();
  let output = '';
  snapshot.forEach(doc => {
    const data = doc.data();
    output += `Report: ${doc.id}\n`;
    output += `Reporter ID: ${data.reporterId}\n`;
    output += `Reported UID: ${data.reportedUid}\n`;
    output += `Reported User ID: ${data.reportedUserId}\n`;
    output += `Target User ID: ${data.targetUserId}\n`;
    output += `Role: ${data.reporterRole} reporting ${data.reportedRole}\n`;
    output += '---\n';
  });
  fs.writeFileSync('reports_dump.txt', output);
  console.log('Done');
}

checkReports();
