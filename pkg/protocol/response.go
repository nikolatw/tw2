package protocol

import "encoding/json"

type Response struct {
	Output   interface{}
	HasError bool
	Error    string
}

func (r Response) Marshal() string {
	r.HasError = r.Error != ""

	data, err := json.Marshal(r)
	if err != nil {
		data, _ := json.Marshal(Response{
			HasError: true,
			Error:    err.Error(),
		})
		return string(data)
	}

	return string(data)
}
