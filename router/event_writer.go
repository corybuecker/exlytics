package router

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/jackc/pgx/v4/pgxpool"
)

type Event map[string]string
type EventWriter struct {
	Database *pgxpool.Pool
	Logger   *log.Logger
}

func (ew *EventWriter) Write(req *http.Request) {
	event := make(Event)

	event["host"] = req.Host
	event["origin"] = req.Header.Get("Origin")
	event["referer"] = req.Header.Get("Referer")
	event["user-agent"] = req.UserAgent()

	for key, element := range req.URL.Query() {
		event[key] = element[0]
	}

	body, err := ioutil.ReadAll(req.Body)

	if err != nil {
		ew.Logger.Print(err)
		return
	}

	if len(body) > 0 {
		var objmap map[string]json.RawMessage
		err = json.Unmarshal(body, &objmap)

		if err != nil {
			ew.Logger.Print(err)
			return
		}

		for key, element := range objmap {
			event[key] = string(element)
		}
	}

	ew.Database.Exec(context.Background(), "insert into exlytics.events values (now(), $1)", event)
	ew.Logger.Print(event)
}