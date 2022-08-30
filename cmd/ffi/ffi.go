package main

// #cgo CFLAGS: -g -Wall
// #include <stdlib.h>

import "C"

import (
	"fmt"
	"sync"

	"github.com/nikolatw/taskwire2/internal/handlers"
	"github.com/nikolatw/taskwire2/pkg/protocol"
)

var (
	mux     *protocol.Mux
	muxOnce sync.Once
)

//export Call
func Call(rawChannel *C.char, rawInput *C.char) *C.char {
	channel := C.GoString(rawChannel)
	input := C.GoString(rawInput)

	fmt.Printf("[%s] %v\n", channel, input)

	initMux()

	output := mux.Handle(channel, input)

	return C.CString(output)
}

func initMux() {
	muxOnce.Do(func() {
		mux = protocol.New()
		mux.AddHandler("local:term", handlers.TerminalHandler)
		mux.AddHandler("local:complete", handlers.CompleteHandler)
	})
}

func main() {}
