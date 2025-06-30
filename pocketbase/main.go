package main

import (
	"log"
	"os"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
    	se.Router.GET(
        	"/{path...}",
        	apis.Static(os.DirFS(".output/public"), true),
    	).BindFunc(func(e *core.RequestEvent) error {
			apis.Gzip()
			return e.Next()
		})
    	return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}

}
