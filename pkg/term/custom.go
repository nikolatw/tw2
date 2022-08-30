package term

import (
	"context"
	"encoding/json"

	"github.com/nikolatw/taskwire2/pkg/term/wired"
	"mvdan.cc/sh/v3/interp"
)

func CustomCommands(args []string, ctx context.Context) (bool, error) {
	if len(args) > 0 {
		var (
			buf []byte
			err error
		)

		switch args[0] {
		case "~ls":
			buf, err = wrap("files", wired.ListDir)(args[1:])
		}

		if buf != nil {
			interp.HandlerCtx(ctx).Stdout.Write(buf)
			if err != nil {
				return true, err
			}
			return true, nil
		}

		if err != nil {
			return true, err
		}
	}

	return false, nil
}

type Wraped struct {
	TaskWireTUI       interface{}
	TaskWireTUISchema string
}

func wrap(wiredType string, wiredFunc func([]string) (interface{}, error)) func([]string) ([]byte, error) {
	return func(args []string) ([]byte, error) {
		v, err := wiredFunc(args)

		if marshalled, ok := v.([]byte); ok {
			return marshalled, err
		}

		data, err := json.Marshal(Wraped{
			TaskWireTUI:       v,
			TaskWireTUISchema: wiredType,
		})
		if err != nil {
			panic(err)
		}

		return data, err
	}
}
