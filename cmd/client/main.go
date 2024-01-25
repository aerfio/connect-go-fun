package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"connectrpc.com/connect"

	greetv1 "aerf.io/connect-go-fun/gen/greet/v1"
	"aerf.io/connect-go-fun/gen/greet/v1/greetv1connect"
)

func main() {
	serverURL := os.Getenv("APP_SERVER_URL")
	if serverURL == "" {
		serverURL = "http://localhost:8080"
	}

	client := greetv1connect.NewGreetServiceClient(
		http.DefaultClient,
		serverURL,
		connect.WithGRPC(),
	)

	for i := 0; i < 1000_000_000; i++ {
		time.Sleep(3 * time.Second)
		res, err := client.Greet(
			context.Background(),
			connect.NewRequest(&greetv1.GreetRequest{
				Name: "Jane",
			}),
		)
		if err != nil {
			log.Println(err)
		} else {
			log.Println(res.Msg.Greeting)
		}
	}
}
