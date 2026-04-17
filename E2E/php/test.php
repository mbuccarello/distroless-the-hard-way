<?php
echo "--------------------------------------------------\n";
echo "🚀 Opensource Distroless E2E Verification (PHP)\n";
echo "--------------------------------------------------\n";

// 1. Verify Runtime
echo "✅ Runtime status: ACTIVE\n";
echo "✅ PHP Version: " . phpversion() . "\n";

// 2. Verify SSL (Opensource OpenSSL)
$ch = curl_init("https://www.google.com");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode == 200 || $httpCode == 301 || $httpCode == 302) {
    echo "✅ SSL Verification: SUCCESS (Handshake with google.com verified via Opensource OpenSSL)\n";
} else {
    echo "❌ SSL Verification: FAILED (HTTP Code: $httpCode)\n";
    exit(1);
}

// 3. Verify Timezone (Opensource TZData)
try {
    $now = new DateTime("now", new DateTimeZone("Europe/Rome"));
    echo "✅ Timezone Verification: SUCCESS (Europe/Rome resolved to " . $now->format("H:i:s") . ")\n";
} catch (Exception $e) {
    echo "❌ Timezone Verification: FAILED - " . $e->getMessage() . "\n";
    exit(1);
}

echo "--------------------------------------------------\n";
echo "✨ All Opensource Systems Verified!\n";
echo "--------------------------------------------------\n";
?>
