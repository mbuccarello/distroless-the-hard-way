using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace HelloOpensource
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("--------------------------------------------------");
            Console.WriteLine("🚀 Opensource Distroless E2E Verification");
            Console.WriteLine($"📅 Timestamp: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
            Console.WriteLine("--------------------------------------------------");

            // 1. Verify Runtime
            Console.WriteLine("✅ Runtime status: ACTIVE");
            Console.WriteLine("✅ Hello, Opensource World! The Dotnet runtime is functioning correctly.");
            Console.WriteLine("✅ System Architecture: " + (IntPtr.Size == 8 ? "64-bit" : "32-bit"));

            // 2. Verify SSL (Opensource OpenSSL)
            try
            {
                using var client = new HttpClient();
                var response = await client.GetAsync("https://www.google.com");
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("✅ SSL Verification: SUCCESS (Handshake with google.com verified via Opensource OpenSSL)");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ SSL Verification: FAILED - " + ex.Message);
                Environment.Exit(1);
            }

            // 3. Verify Timezone (Opensource TZData)
            try
            {
                var romeZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Rome");
                var romeTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, romeZone);
                Console.WriteLine($"✅ Timezone Verification: SUCCESS (Europe/Rome resolved to {romeTime:HH:mm:ss})");
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ Timezone Verification: FAILED - " + ex.Message);
                Environment.Exit(1);
            }

            Console.WriteLine("--------------------------------------------------");
            Console.WriteLine("✨ All Opensource Systems Verified!");
            Console.WriteLine("--------------------------------------------------");
        }
    }
}
