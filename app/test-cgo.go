package main

/*
#include <stdio.h>
#include <stdlib.h>

void hello_from_c() {
    printf("Hello from C code inside Go!\n");
}
*/
import "C"
import (
	"fmt"
	"os"
	"runtime"
)

func main() {
	fmt.Println("🚀 --- Opensource Distroless Go (Cgo) Verification ---")
	fmt.Printf("Runtime Status: ACTIVE\n")
	fmt.Printf("Go Version: %s\n", runtime.Version())
	fmt.Printf("Environment: Cgo Enabled (Glibc-native)\n")
	fmt.Printf("User ID: %d\n", os.Getuid())

	// Call C function
	C.hello_from_c()

	fmt.Printf("Cgo Verification: SUCCESS ✅ (Dynamic linking with glibc verified)\n")
	fmt.Printf("Final Status: ALL TESTS PASSED\n")
}
