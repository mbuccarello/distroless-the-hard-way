const https = require('https');

async function verifySSL() {
    return new Promise((resolve, reject) => {
        https.get('https://www.google.com', (res) => {
            if (res.statusCode === 200) {
                console.log('✅ SSL Verification: SUCCESS (Handshake with google.com verified via Opensource OpenSSL)');
                resolve();
            } else {
                reject(new Error(`Unexpected status code: ${res.statusCode}`));
            }
        }).on('error', (e) => {
            console.error(`❌ SSL Verification: FAILED - ${e.message}`);
            reject(e);
        });
    });
}

function verifyTimezone() {
    try {
        const romeTime = new Intl.DateTimeFormat('en-GB', {
            timeZone: 'Europe/Rome',
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric'
        }).format(new Date());
        console.log(`✅ Timezone Verification: SUCCESS (Europe/Rome resolved to ${romeTime})`);
    } catch (e) {
        console.error(`❌ Timezone Verification: FAILED - ${e.message}`);
        process.exit(1);
    }
}

async function main() {
    console.log("--------------------------------------------------");
    console.log("🚀 Opensource Distroless E2E Verification (Node.js)");
    console.log(`📅 Timestamp: ${new Date().toISOString()} UTC`);
    console.log("--------------------------------------------------");

    console.log("✅ Runtime status: ACTIVE");
    console.log(`✅ System Architecture: ${process.arch}`);

    try {
        await verifySSL();
        verifyTimezone();
        console.log("--------------------------------------------------");
        console.log("✨ All Opensource Systems Verified!");
        console.log("--------------------------------------------------");
    } catch (e) {
        process.exit(1);
    }
}

main();
