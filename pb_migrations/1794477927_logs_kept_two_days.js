/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const settings = app.settings()
  settings.logs.maxDays = 2
  app.save(settings)
})
