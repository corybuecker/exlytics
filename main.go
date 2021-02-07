package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/corybuecker/exlytics/router"
	"github.com/jackc/pgx/v4/pgxpool"
)

func main() {
	dbpool, err := pgxpool.Connect(context.Background(), os.Getenv("DATABASE_URL"))

	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}

	defer dbpool.Close()

	eventWriter := &router.EventWriter{Database: dbpool, Logger: log.New(os.Stdout, "", log.Ldate|log.Ltime|log.Lshortfile)}
	router := router.NewRouter(eventWriter)

	s := &http.Server{
		Addr:    ":8080",
		Handler: router.Handler,
	}

	log.Fatal(s.ListenAndServe())
}
