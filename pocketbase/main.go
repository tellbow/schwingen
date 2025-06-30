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
			// Add HSTS header - only for HTTPS
			if e.Request.TLS != nil {
				e.Response.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
			}
			// Add Gzip middleware
			apis.Gzip()
			return e.Next()
		})
    	return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}

}
