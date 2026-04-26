import java.util.Properties;
import java.net.URL;
import java.net.URLConnection;

public class test {
    public static void main(String[] args) {
        System.out.println("--- Java Sovereign Smoke Test ---");
        System.out.println("Version: " + System.getProperty("java.version"));
        System.out.println("Vendor: " + System.getProperty("java.vendor"));
        System.out.println("OS: " + System.getProperty("os.name") + " (" + System.getProperty("os.arch") + ")");

        try {
            System.out.print("SSL Verification: Testing connection to google.com... ");
            URL url = new URL("https://www.google.com");
            URLConnection conn = url.openConnection();
            conn.setConnectTimeout(5000);
            conn.connect();
            System.out.println("SUCCESS ✅");
        } catch (Exception e) {
            System.out.println("FAILED ❌");
            e.printStackTrace();
            System.exit(1);
        }

        System.out.println("[SUCCESS] Java execution confirmed.");
    }
}
