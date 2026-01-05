package main

import (
	"crypto/rand"
	"fmt"
	"os"
	"time"

	"github.com/oklog/ulid/v2"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "generate":
		generateULID()
	case "validate":
		if len(os.Args) < 3 {
			fmt.Println("Error: validate command requires a ULID argument")
			printUsage()
			os.Exit(1)
		}
		validateULID(os.Args[2])
	default:
		fmt.Printf("Error: unknown command '%s'\n", command)
		printUsage()
		os.Exit(1)
	}
}

func generateULID() {
	t := time.Now()
	entropy := rand.Reader
	id := ulid.MustNew(ulid.Timestamp(t), entropy)
	fmt.Println(id.String())
}

func validateULID(ulidStr string) {
	_, err := ulid.Parse(ulidStr)
	if err != nil {
		fmt.Printf("Invalid ULID: %s\n", err)
		os.Exit(1)
	}
	fmt.Println("Valid ULID")
}

func printUsage() {
	fmt.Println("Usage:")
	fmt.Println("  ./ulid generate")
	fmt.Println("  ./ulid validate <ulid>")
}
