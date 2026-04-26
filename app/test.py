import sys
import os
import platform

print("--- Python Sovereign Smoke Test ---")
print(f"Version: {sys.version}")
print(f"Platform: {platform.platform()}")

# Check for core functional capabilities
modules = ['sqlite3', 'ctypes', 'ssl', 'bz2', 'lzma', 'readline']
for mod in modules:
    try:
        __import__(mod)
        print(f"[OK] Module '{mod}' is loaded.")
    except ImportError as e:
        print(f"[FAIL] Module '{mod}' is MISSING: {e}")
        sys.exit(1)

# Check for Shared Library Path (RPATH)
print(f"Executable: {sys.executable}")

# Functional Check: SQLite3
import sqlite3
db = sqlite3.connect(':memory:')
db.execute("CREATE TABLE test (val TEXT)")
db.execute("INSERT INTO test VALUES ('Sovereign')")
res = db.execute("SELECT val FROM test").fetchone()[0]
if res == "Sovereign":
    print("[OK] SQLite3 works.")
else:
    print("[FAIL] SQLite3 failed.")
    sys.exit(1)

print("[SUCCESS] Python sovereign execution confirmed.")
