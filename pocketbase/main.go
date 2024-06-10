package main

import (
	"embed"
	"log"
	"os"
	"net/http"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

//go:embed all:.output/public
var public embed.FS

func main() {
	app := pocketbase.New()

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.GET("/*", apis.StaticDirectoryHandler(echo.MustSubFS(public, ".output/public"), true))
		env := os.Getenv("GO_ENV")
		if len(env) != 0 {
			//e.Router.GET("/_/*", apis.StaticDirectoryHandler(echo.MustSubFS(public, ".output/foo"), true))
			e.Router.GET("/_/*", func(c echo.Context) error {
				return c.String(http.StatusForbidden, "Pocketbase UI access forbidden!")
			})
		}
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}

}
