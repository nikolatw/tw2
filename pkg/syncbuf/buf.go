package syncbuf

import (
	"bytes"
	"sync"
)

type Buffer struct {
	bytes.Buffer
	Lock sync.Mutex
}

func (b *Buffer) Write(p []byte) (n int, err error) {
	b.Lock.Lock()
	defer b.Lock.Unlock()
	return b.Buffer.Write(p)
}
