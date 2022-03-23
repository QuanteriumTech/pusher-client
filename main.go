package pClient

//#cgo CFLAGS: -x objective-c -fobjc-arc
//#cgo LDFLAGS: -lobjc -framework Foundation -framework CoreServices -framework Security
//#import <main.h>
import "C"
import "fmt"

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

func (pusher *pusherController) StartPusher(key, authEndpoint, channel, UserAuth string) {
	C.startPusher(C.CString(key), C.CString(authEndpoint), C.CString(channel), C.CString(UserAuth))
}

//export receiveMsg
func receiveMsg(msg *C.char) {
	goMsg := C.GoString(msg)
	Pusher.Messages <- goMsg
}

//export updateStatus
func updateStatus(msg *C.char) {
	fmt.Println("got ms")
	goMsg := C.GoString(msg)
	Pusher.Status <- goMsg
}
