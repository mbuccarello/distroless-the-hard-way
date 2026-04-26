<?php
echo "--- PHP Sovereign Smoke Test ---\n";
echo "Version: " . PHP_VERSION . "\n";

$extensions = ['xml', 'sqlite3', 'ffi', 'mbstring', 'openssl', 'zlib'];
foreach ($extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "[OK] Extension '$ext' is loaded.\n";
    } else {
        echo "[FAIL] Extension '$ext' is MISSING!\n";
        exit(1);
    }
}

echo "--- Functional Check: XML ---\n";
$xml = simplexml_load_string("<root><node>Sovereign</node></root>");
if ($xml->node == "Sovereign") {
    echo "[OK] XML parsing works.\n";
} else {
    echo "[FAIL] XML parsing failed.\n";
    exit(1);
}

echo "--- Functional Check: SQLite3 ---\n";
$db = new SQLite3(':memory:');
$db->exec("CREATE TABLE test (val TEXT)");
$db->exec("INSERT INTO test VALUES ('Sovereign')");
$res = $db->querySingle("SELECT val FROM test");
if ($res == "Sovereign") {
    echo "[OK] SQLite3 works.\n";
} else {
    echo "[FAIL] SQLite3 failed.\n";
    exit(1);
}

echo "[SUCCESS] All sovereign checks passed.\n";
?>
