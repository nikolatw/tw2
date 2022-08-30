package tree

import (
	"fmt"
	"time"
)

const unit = 1024

type FileStat struct {
	FullPath string
	Size     string
	Time     time.Time
	Mod      string
}

type FileTree struct {
	Stats  *FileStat            `json:",omitempty"`
	Childs map[string]*FileTree `json:",omitempty"`
}

func (fs *FileStat) SetSize(b int64) {
	if b < unit {
		fs.Size = fmt.Sprintf("%d B", b)
		return
	}

	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}

	fs.Size = fmt.Sprintf("%.1f %ciB", float64(b)/float64(div), "KMGTPE"[exp])
}
