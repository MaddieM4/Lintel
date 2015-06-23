package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type EndpointSpec struct {
	Yours    string   `json:"base_yours"`
	Mine     string   `json:"base_mine"`
	Children []string `json:"children"`
}

var endpoints = []EndpointSpec{
	{
		"/api/", "/api/",
		[]string{"wait/1s"},
	},
}

type jsonCallback func(r *http.Request) (result interface{}, err error)
type httpCallback func(w http.ResponseWriter, r *http.Request)

func MakeCallback(original jsonCallback) httpCallback {
	return func(w http.ResponseWriter, r *http.Request) {
		obj, err := original(r)
		if err != nil {
			http.Error(w, err.Error(), 500)
		}
		enc := json.NewEncoder(w)
		enc.Encode(obj)
	}
}

func available(r *http.Request) (result interface{}, err error) {
	return endpoints, nil
}

func wait1(r *http.Request) (result interface{}, err error) {
	timer := struct {
		Started, Ended time.Time
	}{Started: time.Now()}
	time.Sleep(1 * time.Second)
	timer.Ended = time.Now()
	return timer, nil
}

func route(path string, callback jsonCallback) {
	http.HandleFunc(path, MakeCallback(callback))
}

func main() {
	route("/api/available", available)
	route("/api/wait/1s", wait1)
	log.Fatal(http.ListenAndServe(":9092", nil))
}
