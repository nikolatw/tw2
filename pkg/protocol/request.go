package protocol

import "encoding/json"

type Request struct {
	RawData string
}

func (r *Request) Unmarshal(v interface{}) error {
	return json.Unmarshal([]byte(r.RawData), v)
}
