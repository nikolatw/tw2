package handlers

import (
	"github.com/nikolatw/taskwire2/pkg/complete"
	"github.com/nikolatw/taskwire2/pkg/protocol"
)

type (
	CompleteRequest struct {
		TermID  string
		Command string
	}
	CompleteResponse struct {
		Suggestions []string
	}
)

func CompleteHandler(request protocol.Request) protocol.Response {
	var req CompleteRequest
	err := request.Unmarshal(&req)
	if err != nil {
		return protocol.Response{
			Error: err.Error(),
		}
	}

	suggestions, err := complete.Complete(req.TermID, req.Command)
	if err != nil {
		return protocol.Response{
			Error: err.Error(),
		}
	}

	return protocol.Response{
		Output: CompleteResponse{
			Suggestions: suggestions,
		},
	}
}
