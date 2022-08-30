package protocol

type Mux struct {
	Handlers map[string]func(Request) Response
}

func New() *Mux {
	return &Mux{
		Handlers: make(map[string]func(Request) Response),
	}
}

func (m *Mux) AddHandler(channel string, handler func(Request) Response) {
	m.Handlers[channel] = handler
}

func (m *Mux) Handle(channel string, data string) string {
	return m.Handlers[channel](Request{
		RawData: data,
	}).Marshal()
}
