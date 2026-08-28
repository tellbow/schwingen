/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const years = [2015, 2016, 2017, 2018, 2019, 2021, 2022, 2023, 2024, 2025, 2026]
  for (const year of years) {
    const collection = app.findCollectionByNameOrId(`elo${year}`)
    collection.createRule = null
    collection.updateRule = null
    collection.deleteRule = null
    app.save(collection)
  }
}, (app) => {
  const years = [2015, 2016, 2017, 2018, 2019, 2021, 2022, 2023, 2024, 2025, 2026]
  for (const year of years) {
    const collection = app.findCollectionByNameOrId(`elo${year}`)
    collection.createRule = ""
    collection.updateRule = ""
    collection.deleteRule = ""
    app.save(collection)
  }
})
