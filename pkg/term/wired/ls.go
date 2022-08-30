package wired

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/nikolatw/taskwire2/pkg/term/tools"
	"github.com/nikolatw/taskwire2/pkg/tree"
)

func ListDir(args []string) (interface{}, error) {
	base := "."
	if len(args) > 0 {
		base = filepath.Join(base, args[0])
	}

	realpath, err := filepath.Abs(base)
	if err != nil {
		return tools.Fail(err)
	}

	files := tree.FileTree{
		Childs: make(map[string]*tree.FileTree),
	}

	err = filepath.Walk(realpath, func(fullPath string, info fs.FileInfo, err error) error {
		if info == nil {
			return os.ErrNotExist
		}

		fullPath = strings.TrimPrefix(fullPath, realpath)
		fullPath = strings.ReplaceAll(fullPath, "\\", "/")
		fullPath = strings.Trim(fullPath, "/")

		if fullPath == "" {
			files.Stats = &tree.FileStat{
				FullPath: realpath + "/" + fullPath,
				Time:     info.ModTime(),
				Mod:      info.Mode().String(),
			}
			return nil
		}

		path := strings.Split(fullPath, "/")
		current := &files

		for i, loc := range path {
			if i != len(path)-1 {
				if _, ok := current.Childs[loc]; !ok {
					current.Childs[loc] = &tree.FileTree{
						Childs: make(map[string]*tree.FileTree),
						Stats: &tree.FileStat{
							FullPath: realpath + "/" + fullPath,
							Time:     info.ModTime(),
							Mod:      info.Mode().String(),
						},
					}
				}
				current = current.Childs[loc]
				continue
			}

			if !info.IsDir() {
				stat := &tree.FileStat{
					FullPath: realpath + "/" + fullPath,
					Time:     info.ModTime(),
					Mod:      info.Mode().String(),
				}
				stat.SetSize(info.Size())
				current.Childs[loc] = &tree.FileTree{
					Stats: stat,
				}
			}
		}

		return nil
	})
	if err != nil {
		return tools.Fail(err)
	}

	return files, nil
}
