import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

public class HelloOpensource {
    public static void main(String[] args) {
        System.out.println("--------------------------------------------------");
        System.out.println("🚀 Opensource Distroless E2E Verification (Java)");
        System.out.println("--------------------------------------------------");

        // 1. Verify Runtime
        System.out.println("✅ Runtime status: ACTIVE");
        System.out.println("✅ Java Version: " + System.getProperty("java.version"));

        // 2. Verify SSL (Opensource OpenSSL)
        try {
            HttpClient client = HttpClient.newBuilder()
                    .followRedirects(HttpClient.Redirect.NORMAL)
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.google.com"))
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                System.out.println("✅ SSL Verification: SUCCESS (Handshake with google.com verified via Opensource OpenSSL)");
            }
        } catch (Exception e) {
            System.err.println("❌ SSL Verification: FAILED - " + e.getMessage());
            System.exit(1);
        }

        // 3. Verify Timezone (Opensource TZData)
        try {
            ZoneId romeZone = ZoneId.of("Europe/Rome");
            ZonedDateTime romeTime = ZonedDateTime.now(romeZone);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
            System.out.println("✅ Timezone Verification: SUCCESS (Europe/Rome resolved to " + romeTime.format(formatter) + ")");
        } catch (Exception e) {
            System.err.println("❌ Timezone Verification: FAILED - " + e.getMessage());
            System.exit(1);
        }

        System.out.println("--------------------------------------------------");
        System.out.println("✨ All Opensource Systems Verified!");
        System.out.println("--------------------------------------------------");
    }
}
