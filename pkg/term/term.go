package term

import (
	"context"
	"fmt"
	"os"
	"sync"
	"time"

	"github.com/nikolatw/taskwire2/pkg/syncbuf"
	"mvdan.cc/sh/v3/expand"
	"mvdan.cc/sh/v3/interp"
)

type TerminalModel struct {
	Shell        *interp.Runner
	In           syncbuf.Buffer
	Out          syncbuf.Buffer
	Lock         sync.Mutex
	LastExitCode uint8
}

var (
	terminalStorage     map[string]*TerminalModel
	terminalStorageLock sync.Mutex
)

func GetTerm(termID string) (*TerminalModel, error) {
	if terminalStorage == nil {
		terminalStorageLock.Lock()
		terminalStorage = make(map[string]*TerminalModel)
		terminalStorageLock.Unlock()
	}

	_, ok := terminalStorage[termID]
	if !ok {
		t := &TerminalModel{}

		fmt.Printf("  (%s) new terminal\n", termID)

		env := os.Environ()
		env = append(env, "TERM=xterm")
		env = append(env, "TASKWIRE_TUI=^2.0.1")

		shellExec := interp.DefaultExecHandler(time.Hour)

		shell, err := interp.New(
			interp.StdIO(&t.In, &t.Out, &t.Out),
			interp.Env(expand.ListEnviron(env...)),
			interp.ExecHandler(func(ctx context.Context, args []string) error {
				found, exitCode := CustomCommands(args, ctx)
				if found {
					return exitCode
				}

				return shellExec(ctx, args)
			}),
		)
		if err != nil {
			return nil, err
		}
		t.Shell = shell

		terminalStorageLock.Lock()
		terminalStorage[termID] = t
		terminalStorageLock.Unlock()
	}

	return terminalStorage[termID], nil
}
