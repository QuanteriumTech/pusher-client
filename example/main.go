package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	pClient "github.com/QuanteriumTech/pusher-client"

	pusherLib "github.com/pusher/pusher-http-go/v5"
)

// ---------- Go Client ----------

type Message struct {
	Message string
}

func main() {
	connected := false
	ch := make(chan interface{})
	// bridge
	go func() {
		for msg := range pClient.Pusher.Messages {
			MsgStruct := &Message{}
			json.Unmarshal([]byte(msg), MsgStruct)
			fmt.Println(MsgStruct)
		}
	}()
	go func() {
		for msg := range pClient.Pusher.Status {
			fmt.Println(msg)
			if msg == "connected" && !connected {
				connected = true
				go pClient.Pusher.SubscribeToChannel(
					"private-my-channel",                // channel name
					"auth",                              // user auth token issued by Compose
					"http://127.0.0.1:8090/pusher/auth", //authentication endpoint in capi
				)
			}
		}
	}()

	// go func() {
	// 	time.Sleep(10 * time.Second)
	// 	fmt.Println("Unsubbing")
	// 	pClient.Pusher.UnsubscribeFromChannel()
	// }()

	pClient.Pusher.StartPusher(
		"abc", //pusher env id (this is dev)
	)

	<-ch
}

// ---------- Go Server ----------

var pusherClient *pusherLib.Client

func init() {
	pusherClient = &pusherLib.Client{
		AppID:   "1234",
		Key:     "abc",
		Secret:  "shush!",
		Cluster: "eu",
		Secure:  true,
	}
	go func() {
		http.HandleFunc("/pusher/auth", auth)
		http.ListenAndServe(":8090", nil)
	}()
	go func() {
		time.Sleep(5 * time.Second)
		send("hello world")
	}()

	go func() {
		time.Sleep(15 * time.Second)
		send("hi?")
	}()
}

func auth(res http.ResponseWriter, req *http.Request) {
	// this auths anyone - need to ensure that auth header is valid and user has access to requested channel.
	params, _ := ioutil.ReadAll(req.Body)

	// part 1: Compose auth. Where we need to check the auth token and ensure that it is issued by Compose and matches the user id for the requested channel.
	// params.auth == user.session.token && params.channel.getUserIDFromChannelName == session.user.id

	// part 2: Get a pusher auth token
	response, err := pusherClient.AuthenticatePrivateChannel(params)

	if err != nil {
		fmt.Println("error: ", err)
	}

	fmt.Fprintf(res, string(response))
}

func send(msg string) {
	fmt.Println("Gonna send event")
	data := map[string]string{"message": msg}
	pusherClient.Trigger("private-my-channel", "my-event", data)
}
