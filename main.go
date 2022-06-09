package pClient

//#cgo CFLAGS: -x objective-c -fobjc-arc
//#cgo LDFLAGS: -lobjc -framework Foundation -framework CoreServices -framework Security
//#import <main.h>
import "C"

var Pusher *pusherController

type pusherController struct {
	Messages chan string
	Status   chan string
}

func init() {
	Pusher = &pusherController{
		Messages: make(chan string),
		Status:   make(chan string),
	}
}

func (pusher *pusherController) StartPusher(key string) {
	C.startPusher(C.CString(key))
}

func (pusher *pusherController) SubscribeToChannel(channel, UserAuth, authEndpoint string) {
	C.subscribeToChannel(C.CString(channel), C.CString(UserAuth), C.CString(authEndpoint))
}

func (pusher *pusherController) UnsubscribeFromChannel() {
	C.unsubscribeFromChannel()
}

func (pusher *pusherController) Reconnect() {
	C.reconnect()
}

//export receiveMsg
func receiveMsg(msg *C.char) {
	goMsg := C.GoString(msg)
	Pusher.Messages <- goMsg
}

//export updateStatus
func updateStatus(msg *C.char) {
	goMsg := C.GoString(msg)
	Pusher.Status <- goMsg
}
