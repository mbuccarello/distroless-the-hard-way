using System;
using System.Net.Http;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        Console.WriteLine("--- .NET Sovereign Smoke Test ---");
        Console.WriteLine($".NET Version: {Environment.Version}");
        Console.WriteLine($"OS: {Environment.OSVersion}");

        try
        {
            Console.Write("SSL Verification: Testing connection to google.com... ");
            using var client = new HttpClient();
            var response = await client.GetAsync("https://www.google.com");
            response.EnsureSuccessStatusCode();
            Console.WriteLine("SUCCESS ✅");
        }
        catch (Exception e)
        {
            Console.WriteLine("FAILED ❌");
            Console.WriteLine(e.Message);
            Environment.Exit(1);
        }

        Console.WriteLine("[SUCCESS] .NET execution confirmed.");
    }
}
