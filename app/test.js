const https = require('https');

console.log("--- Node.js Sovereign Smoke Test ---");
console.log("Version: " + process.version);
console.log("Platform: " + process.platform);
console.log("Arch: " + process.arch);

https.get('https://www.google.com', (res) => {
    console.log("SSL Verification: Testing connection to google.com... SUCCESS ✅");
    console.log("Status Code:", res.statusCode);
    console.log("[SUCCESS] Node.js execution confirmed.");
    process.exit(0);
}).on('error', (e) => {
    console.error("SSL Verification: Testing connection to google.com... FAILED ❌");
    console.error(e);
    process.exit(1);
});
