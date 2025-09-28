package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type statusResponse struct {
	Service   string    `json:"service"`
	Version   string    `json:"version"`
	Timestamp time.Time `json:"timestamp"`
	Env       string    `json:"env"`
	Database  string    `json:"database"`
}

func main() {
	port := defaultString(os.Getenv("PORT"), "80")
	env := defaultString(os.Getenv("ENV"), "dev")
	dbDsn := os.Getenv("DB_DSN")

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "minimal-gov poc app running in %s\n", env)
	})

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		resp := statusResponse{
			Service:   "minimal-gov-app-poc",
			Version:   defaultString(os.Getenv("APP_VERSION"), "0.1.0"),
			Timestamp: time.Now().UTC(),
			Env:       env,
			Database:  connectionStatus(dbDsn),
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			log.Printf("failed to encode health response: %v", err)
		}
	})

	addr := fmt.Sprintf(":%s", port)
	log.Printf("starting poc app on %s (env=%s)", addr, env)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

func connectionStatus(dsn string) string {
	if dsn == "" {
		return "not-configured"
	}
	return "configured"
}

func defaultString(value, fallback string) string {
	if value == "" {
		return fallback
	}
	return value
}
