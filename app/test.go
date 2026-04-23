package main

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"time"
)

func main() {
	fmt.Println("🚀 --- Opensource Distroless Go Verification ---")
	fmt.Printf("Runtime Status: ACTIVE\n")
	fmt.Printf("Go Version: %s\n", runtime.Version())
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Printf("User ID: %d\n", os.Getuid())

	// Test SSL Handshake
	client := &http.Client{
		Timeout: 10 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: false},
		},
	}

	fmt.Printf("SSL Verification: Testing connection to google.com... ")
	resp, err := client.Get("https://www.google.com")
	if err != nil {
		fmt.Printf("FAILED ❌\nError: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()
	fmt.Printf("SUCCESS ✅ (Handshake verified via Sovereign Root Trust Store)\n")

	fmt.Printf("Final Status: ALL TESTS PASSED\n")
}
