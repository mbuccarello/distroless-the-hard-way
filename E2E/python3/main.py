import urllib.request
import time
from datetime import datetime
import zoneinfo

def verify_ssl():
    try:
        with urllib.request.urlopen("https://www.google.com", timeout=10) as response:
            if response.status == 200:
                print("✅ SSL Verification: SUCCESS (Handshake with google.com verified via Opensource OpenSSL)")
    except Exception as e:
        import ssl
        print(f"❌ SSL Verification: FAILED - {e}")
        print(f"DEBUG: Default verify paths: {ssl.get_default_verify_paths()}")
        exit(1)

def verify_timezone():
    try:
        rome_zone = zoneinfo.ZoneInfo("Europe/Rome")
        rome_time = datetime.now(rome_zone)
        print(f"✅ Timezone Verification: SUCCESS (Europe/Rome resolved to {rome_time.strftime('%H:%M:%S')})")
    except Exception as e:
        print(f"❌ Timezone Verification: FAILED - {e}")
        exit(1)

def main():
    print("--------------------------------------------------")
    print("🚀 Opensource Distroless E2E Verification (Python 3)")
    print(f"📅 Timestamp: {datetime.utcnow().isoformat()} UTC")
    print("--------------------------------------------------")

    print("✅ Runtime status: ACTIVE")
    
    verify_ssl()
    verify_timezone()

    print("--------------------------------------------------")
    print("✨ All Opensource Systems Verified!")
    print("--------------------------------------------------")

if __name__ == "__main__":
    main()
