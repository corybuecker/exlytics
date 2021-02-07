package router

import (
	"net/http"
)

type Router struct {
	Handler     *http.ServeMux
	EventWriter *EventWriter
}

func NewRouter(ew *EventWriter) (r *Router) {
	mux := http.NewServeMux()

	r = &Router{Handler: mux, EventWriter: ew}

	mux.HandleFunc("/healthcheck", healthcheck)
	mux.HandleFunc("/", saveEvent(r.EventWriter))

	return r
}

func healthcheck(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	w.Write([]byte("OK"))
}

func saveEvent(ew *EventWriter) func(w http.ResponseWriter, req *http.Request) {
	return func(w http.ResponseWriter, req *http.Request) {
		ew.Write(req)
		w.WriteHeader(http.StatusCreated)
	}
}
