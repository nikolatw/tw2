package handlers

import (
	"context"
	"strings"

	"github.com/nikolatw/taskwire2/pkg/protocol"
	"github.com/nikolatw/taskwire2/pkg/term"
	"mvdan.cc/sh/v3/interp"
	"mvdan.cc/sh/v3/syntax"
)

type (
	TerminalRequest struct {
		TermID  string
		Command string
	}
	TerminalResponse struct {
		Out      string
		ExitCode int
		Prompt   string
	}
)

func TerminalHandler(request protocol.Request) protocol.Response {
	req := TerminalRequest{}
	err := request.Unmarshal(&req)
	if err != nil {
		return protocol.Response{
			Error: err.Error(),
		}
	}

	t, err := term.GetTerm(req.TermID)
	if err != nil {
		return protocol.Response{
			Error: err.Error(),
		}
	}
	t.Lock.Lock()
	defer t.Lock.Unlock()

	t.In.Reset()
	t.Out.Reset()

	prog, err := syntax.NewParser().Parse(strings.NewReader(req.Command), req.TermID)
	if err != nil {
		return protocol.Response{
			Output: TerminalResponse{
				Out:      t.Out.String(),
				Prompt:   term.BuildPrompt(t),
				ExitCode: 1,
			},
			Error: err.Error(),
		}
	}

	err = t.Shell.Run(context.Background(), prog)
	if err != nil {
		t.LastExitCode, _ = interp.IsExitStatus(err)
		return protocol.Response{
			Output: TerminalResponse{
				Out:      t.Out.String(),
				Prompt:   term.BuildPrompt(t),
				ExitCode: int(t.LastExitCode),
			},
			Error: err.Error(),
		}
	}

	t.LastExitCode = 0

	return protocol.Response{
		Output: TerminalResponse{
			Out:      t.Out.String(),
			Prompt:   term.BuildPrompt(t),
			ExitCode: int(t.LastExitCode),
		},
	}
}
