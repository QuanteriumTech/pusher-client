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
	// bridge
	go func() {
		for msg := range pClient.Pusher.Messages {
			MsgStruct := &Message{}
			json.Unmarshal([]byte(msg), MsgStruct)
			fmt.Println(MsgStruct)
		}
	}()
	pClient.Pusher.StartPusher(
		"3d41671bd9378ccdd519",              //pusher env id (this is dev)
		"http://127.0.0.1:8090/pusher/auth", //authentication endpoint in capi
		"private-my-channel",                // channel name
		"auth",                              // user auth token issued by Compose
	)
}

// ---------- Go Server ----------

var pusherClient *pusherLib.Client

func init() {
	pusherClient = &pusherLib.Client{
		AppID:   "1363149",
		Key:     "3d41671bd9378ccdd519",
		Secret:  "a5fc1c91d9507fd9e7bd",
		Cluster: "eu",
		Secure:  true,
	}
	go func() {
		http.HandleFunc("/pusher/auth", auth)
		http.ListenAndServe(":8090", nil)
	}()
	go func() {
		time.Sleep(5 * time.Second)
		send()
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

func send() {
	fmt.Println("Gonna send event")
	data := map[string]string{"message": "hello world"}
	pusherClient.Trigger("private-my-channel", "my-event", data)
}
