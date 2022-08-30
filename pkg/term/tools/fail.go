package tools

import (
	"bytes"
	"fmt"

	"mvdan.cc/sh/v3/interp"
)

func Fail(err error) ([]byte, error) {
	buf := bytes.Buffer{}
	fmt.Fprintf(&buf, "wired fail: %v", err)
	return buf.Bytes(), interp.NewExitStatus(1)
}
