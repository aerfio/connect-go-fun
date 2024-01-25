package main

import (
	"fmt"
	"log/slog"
	"os"
	"time"

	greetv1 "aerf.io/connect-go-fun/gen/greet/v1"
	"github.com/nats-io/nats.go"
	"google.golang.org/protobuf/proto"
)

// just start default nats-server config by running just `nats-server`

func main() {
	url := os.Getenv("NATS_URL")
	if url == "" {
		url = nats.DefaultURL
	}

	nc, err := nats.Connect(url)
	if err != nil {
		slog.Default().Error("failed to connect", "error", err)
		os.Exit(1)
	}
	defer func() {
		if err := nc.Drain(); err != nil {
			slog.Default().Error("nc.Drain", "error", err)
		}
	}()
	nc.Subscribe("greet", func(msg *nats.Msg) {
		var req greetv1.GreetRequest
		proto.Unmarshal(msg.Data, &req)

		rep := greetv1.GreetResponse{
			Greeting: fmt.Sprintf("hello %q!", req.Name),
		}
		data, err := proto.Marshal(&rep)
		if err != nil {
			slog.Default().Error("proto marshal", "error", err)
			msg.Respond([]byte("damn doesnt work"))
			return
		}
		msg.Respond(data)
		msg.Ack()
	})

	req := greetv1.GreetRequest{
		Name: "joe",
	}
	data, _ := proto.Marshal(&req)

	msg, _ := nc.Request("greet", data, time.Second)

	var rep greetv1.GreetResponse
	proto.Unmarshal(msg.Data, &rep)

	fmt.Printf("reply: %s\n", rep.Greeting)
}
